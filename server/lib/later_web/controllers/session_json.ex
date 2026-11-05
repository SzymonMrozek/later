defmodule LaterWeb.SessionJSON do
  alias Later.Accounts.Account

  def show(%{tokens: tokens, account: account}) do
    %{
      access_token: tokens.access_token,
      refresh_token: tokens.refresh_token,
      expires_at: tokens.expires_at,
      account: account(account)
    }
  end

  defp account(%Account{} = account) do
    %{id: account.id, kind: account.kind, email: account.email}
  end
end
