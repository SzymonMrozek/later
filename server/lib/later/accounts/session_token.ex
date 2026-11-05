defmodule Later.Accounts.SessionToken do
  @moduledoc """
  One signed-in session: a short-lived access token and the refresh token that renews it.
  Only hashes of the tokens are stored.
  """
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @token_bytes 32
  @access_seconds 60 * 60
  @refresh_seconds 90 * 24 * 60 * 60

  schema "session_tokens" do
    field :access_token_hash, :binary
    field :access_expires_at, :utc_datetime
    field :refresh_token_hash, :binary
    field :refresh_expires_at, :utc_datetime
    belongs_to :account, Later.Accounts.Account

    timestamps(type: :utc_datetime)
  end

  @doc """
  Returns new tokens for `account` and the struct to insert for them.
  """
  def build(account, now) do
    {tokens, fields} = issue(now)
    {tokens, struct!(__MODULE__, Keyword.put(fields, :account_id, account.id))}
  end

  @doc """
  Returns new tokens and the fields that replace a session's current ones.

  The tokens are `%{access_token:, refresh_token:, expires_at:}`, as the API returns them.
  """
  def issue(now) do
    access_token = generate()
    refresh_token = generate()
    expires_at = DateTime.add(now, @access_seconds)

    fields = [
      access_token_hash: hash(access_token),
      access_expires_at: expires_at,
      refresh_token_hash: hash(refresh_token),
      refresh_expires_at: DateTime.add(now, @refresh_seconds)
    ]

    {%{access_token: access_token, refresh_token: refresh_token, expires_at: expires_at}, fields}
  end

  def hash(token), do: :crypto.hash(:sha256, token)

  defp generate do
    @token_bytes |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false)
  end
end
