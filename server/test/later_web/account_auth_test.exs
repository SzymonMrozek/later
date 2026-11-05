defmodule LaterWeb.AccountAuthTest do
  use LaterWeb.ConnCase, async: true

  alias Later.Accounts
  alias Later.Accounts.SessionToken
  alias Later.Repo
  alias LaterWeb.AccountAuth

  defp authenticate(conn) do
    conn
    |> Phoenix.Controller.put_format("json")
    |> AccountAuth.call(AccountAuth.init([]))
  end

  test "assigns the account of a valid bearer token", %{conn: conn} do
    {:ok, tokens, account} = Accounts.sign_in_guest(%{"device_id" => Ecto.UUID.generate()})

    conn =
      conn |> put_req_header("authorization", "Bearer #{tokens.access_token}") |> authenticate()

    refute conn.halted
    assert conn.assigns.current_account.id == account.id
  end

  test "halts with 401 for an expired access token", %{conn: conn} do
    {:ok, tokens, _account} = Accounts.sign_in_guest(%{"device_id" => Ecto.UUID.generate()})
    Repo.update_all(SessionToken, set: [access_expires_at: ~U[2026-01-01 00:00:00Z]])

    conn =
      conn |> put_req_header("authorization", "Bearer #{tokens.access_token}") |> authenticate()

    assert conn.halted
    assert json_response(conn, 401)
  end

  test "halts with 401 for a refresh token", %{conn: conn} do
    {:ok, tokens, _account} = Accounts.sign_in_guest(%{"device_id" => Ecto.UUID.generate()})

    conn =
      conn |> put_req_header("authorization", "Bearer #{tokens.refresh_token}") |> authenticate()

    assert conn.halted
    assert json_response(conn, 401)
  end

  test "halts with 401 for an unknown token", %{conn: conn} do
    conn = conn |> put_req_header("authorization", "Bearer nope") |> authenticate()

    assert conn.halted
    assert json_response(conn, 401)
  end

  test "halts with 401 without an authorization header", %{conn: conn} do
    conn = authenticate(conn)

    assert conn.halted
    assert json_response(conn, 401)
  end
end
