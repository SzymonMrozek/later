defmodule LaterWeb.SessionController do
  use LaterWeb, :controller

  alias Later.Accounts

  action_fallback LaterWeb.FallbackController

  def guest(conn, params) do
    with {:ok, token, account} <- Accounts.sign_in_guest(params) do
      render(conn, :show, token: token, account: account)
    end
  end

  def apple(conn, params) do
    with {:ok, token, account} <- Accounts.sign_in_apple(params) do
      render(conn, :show, token: token, account: account)
    end
  end
end
