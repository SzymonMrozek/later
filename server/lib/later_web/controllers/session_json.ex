defmodule LaterWeb.SessionJSON do
  alias Later.Accounts.Account

  def show(%{token: token, account: account}) do
    %{token: token, account: account(account)}
  end

  defp account(%Account{} = account) do
    %{id: account.id, kind: account.kind, email: account.email}
  end
end
