defmodule Later.Accounts do
  @moduledoc """
  Accounts and their sessions: guest accounts per install, Sign in with Apple, access tokens that
  expire within the hour and refresh tokens that renew them.
  """
  import Ecto.Changeset
  import Ecto.Query

  alias Later.Accounts.{Account, AppleIdentity, SessionToken}
  alias Later.Repo

  @doc """
  Signs in as the guest account for `params["device_id"]`, creating it on the first call.

  Returns `{:ok, tokens, account}` or `{:error, changeset}` for invalid params. `tokens` is
  `%{access_token:, refresh_token:, expires_at:}`.
  """
  def sign_in_guest(params) do
    with {:ok, %{device_id: device_id}} <- validate(params, [:device_id], [:device_id]) do
      now = DateTime.utc_now(:second)

      # Inserts or touches the device's guest in one statement, so concurrent calls agree.
      account =
        Repo.insert!(%Account{kind: :guest, device_id: device_id},
          on_conflict: [set: [updated_at: now]],
          conflict_target: :device_id,
          returning: true
        )

      {:ok, create_session(account), account}
    end
  end

  @doc """
  Signs in with Apple. Verifies `identity_token`, finds or creates the account by Apple's `sub`,
  and takes over the guest account of `device_id` when there is one.

  Returns `{:ok, tokens, account}`, `{:error, changeset}` for invalid params,
  `{:error, :invalid_identity_token}` or `{:error, :apple_keys_unavailable}`.
  """
  def sign_in_apple(params) do
    fields = [:device_id, :identity_token, :authorization_code, :given_name, :family_name, :email]

    # `authorization_code` is required by the contract but unused until the server exchanges it
    # with Apple, which needs a client secret signed with the team's private key.
    with {:ok, attrs} <-
           validate(params, fields, [:device_id, :identity_token, :authorization_code]),
         {:ok, claims} <- AppleIdentity.verify(attrs.identity_token),
         # Apple's own email claim wins over what the app sends.
         profile = Map.put(attrs, :email, claims["email"] || attrs[:email]),
         {:ok, {tokens, account}} <-
           Repo.transact(fn -> upsert_apple_account(claims["sub"], attrs.device_id, profile) end) do
      {:ok, tokens, account}
    end
  end

  defp upsert_apple_account(sub, device_id, profile) do
    apple = Repo.get_by(Account, apple_sub: sub)
    guest = Repo.get_by(Account, device_id: device_id, kind: :guest)

    result =
      case {apple, guest} do
        {nil, nil} -> Repo.insert(Account.apple_changeset(%Account{}, sub, profile))
        {nil, guest} -> Repo.update(Account.apple_changeset(guest, sub, profile))
        {apple, guest} -> merge_guest(apple, guest, sub, profile)
      end

    with {:ok, account} <- result do
      {:ok, {create_session(account), account}}
    end
  end

  # The Apple account already exists, so the device's guest moves into it. Library rows will be
  # reassigned to `apple` here once they exist; the guest's sessions go with its account.
  defp merge_guest(apple, guest, sub, profile) do
    if guest, do: Repo.delete!(guest)
    Repo.update(Account.apple_changeset(apple, sub, profile))
  end

  @doc """
  Trades `params["refresh_token"]` for new tokens of the same session. The old refresh token and
  access token stop working.

  Returns `{:ok, tokens, account}`, `{:error, changeset}` for invalid params or
  `{:error, :invalid_refresh_token}` for an unknown, already used or expired refresh token.
  """
  def refresh_session(params) do
    with {:ok, %{refresh_token: refresh_token}} <-
           validate(params, [:refresh_token], [:refresh_token]) do
      now = DateTime.utc_now(:second)
      {tokens, fields} = SessionToken.issue(now)

      # Matching and replacing the hash in one statement lets only one of two concurrent
      # refreshes with the same token win.
      query =
        from t in SessionToken,
          where: t.refresh_token_hash == ^SessionToken.hash(refresh_token),
          where: t.refresh_expires_at > ^now,
          select: t.account_id

      case Repo.update_all(query, set: [updated_at: now] ++ fields) do
        {1, [account_id]} -> {:ok, tokens, Repo.get!(Account, account_id)}
        {0, []} -> {:error, :invalid_refresh_token}
      end
    end
  end

  @doc """
  Returns the account for an access token that hasn't expired, or `nil`.
  """
  def get_account_by_token(token) when is_binary(token) do
    query =
      from t in SessionToken,
        join: a in assoc(t, :account),
        where: t.access_token_hash == ^SessionToken.hash(token),
        where: t.access_expires_at > ^DateTime.utc_now(:second),
        select: a

    Repo.one(query)
  end

  defp create_session(account) do
    {tokens, session_token} = SessionToken.build(account, DateTime.utc_now(:second))
    Repo.insert!(session_token)
    tokens
  end

  defp validate(params, fields, required) do
    types = %{
      device_id: Ecto.UUID,
      identity_token: :string,
      authorization_code: :string,
      given_name: :string,
      family_name: :string,
      email: :string,
      refresh_token: :string
    }

    changeset =
      {%{}, Map.take(types, fields)}
      |> cast(params, fields)
      |> validate_required(required)

    # Every optional field is a profile string.
    (fields -- required)
    |> Enum.reduce(changeset, &validate_length(&2, &1, max: 255))
    |> apply_action(:insert)
  end
end
