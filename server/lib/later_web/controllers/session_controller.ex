defmodule LaterWeb.SessionController do
  use LaterWeb, :controller

  alias Later.Accounts

  action_fallback LaterWeb.FallbackController

  def guest(conn, params) do
    with {:ok, tokens, account} <- Accounts.sign_in_guest(params) do
      render(conn, :show, tokens: tokens, account: account)
    end
  end

  def apple(conn, params) do
    with {:ok, tokens, account} <- Accounts.sign_in_apple(params) do
      render(conn, :show, tokens: tokens, account: account)
    end
  end

  def refresh(conn, params) do
    with {:ok, tokens, account} <- Accounts.refresh_session(params) do
      render(conn, :show, tokens: tokens, account: account)
    end
  end
end
