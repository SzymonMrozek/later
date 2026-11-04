defmodule Later.Accounts.SessionToken do
  @moduledoc """
  One signed-in session. Only a hash of the bearer token is stored.
  """
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @token_bytes 32

  schema "session_tokens" do
    field :token_hash, :binary
    belongs_to :account, Later.Accounts.Account

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc """
  Returns a new token for `account` and the struct to insert for it.
  """
  def build(account) do
    token = @token_bytes |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false)
    {token, %__MODULE__{account_id: account.id, token_hash: hash(token)}}
  end

  def hash(token), do: :crypto.hash(:sha256, token)
end
