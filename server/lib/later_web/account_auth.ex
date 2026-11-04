defmodule LaterWeb.AccountAuth do
  @moduledoc """
  Authenticates API requests by their `Authorization: Bearer <token>` header and assigns
  `:current_account`, or halts with 401.
  """
  import Plug.Conn
  import Phoenix.Controller

  alias Later.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         %Accounts.Account{} = account <- Accounts.get_account_by_token(token) do
      assign(conn, :current_account, account)
    else
      _unauthenticated ->
        conn
        |> put_status(:unauthorized)
        |> put_view(json: LaterWeb.ErrorJSON)
        |> render(:"401")
        |> halt()
    end
  end
end
