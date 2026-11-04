defmodule Later.Accounts.AppleKeys do
  @moduledoc """
  Fetches Apple's public keys for Sign in with Apple identity tokens.

  `Later.Accounts.AppleIdentity` calls the module set as `config :later, :apple_keys`, so tests
  can replace the fetch.
  """

  @callback fetch_keys() :: {:ok, [map()]} | {:error, term()}

  @behaviour __MODULE__

  @keys_url "https://appleid.apple.com/auth/keys"

  @impl true
  def fetch_keys do
    case Req.get(@keys_url, Application.get_env(:later, :apple_keys_req_options, [])) do
      {:ok, %Req.Response{status: 200, body: %{"keys" => keys}}} when is_list(keys) ->
        {:ok, keys}

      _other ->
        {:error, :apple_keys_unavailable}
    end
  end
end
