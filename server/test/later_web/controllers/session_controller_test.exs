defmodule LaterWeb.SessionControllerTest do
  use LaterWeb.ConnCase, async: true

  import Later.AppleIdentityFixtures

  alias Later.Accounts
  alias Later.Accounts.{Account, SessionToken}
  alias Later.Repo

  defp apple_params(overrides \\ %{}) do
    Map.merge(
      %{
        "device_id" => Ecto.UUID.generate(),
        "identity_token" => identity_token(),
        "authorization_code" => "c0de"
      },
      overrides
    )
  end

  describe "POST /api/sessions/guest" do
    test "creates a guest account for a new device", %{conn: conn} do
      device_id = Ecto.UUID.generate()

      assert %{
               "access_token" => token,
               "refresh_token" => refresh_token,
               "expires_at" => expires_at,
               "account" => %{"id" => id, "kind" => "guest", "email" => nil}
             } = conn |> post(~p"/api/sessions/guest", device_id: device_id) |> json_response(200)

      assert %Account{id: ^id, device_id: ^device_id} = Accounts.get_account_by_token(token)
      assert refresh_token != token

      # The access token lasts an hour.
      {:ok, expires_at, 0} = DateTime.from_iso8601(expires_at)
      assert_in_delta DateTime.diff(expires_at, DateTime.utc_now()), 3600, 5
    end

    test "returns the same account for the same device", %{conn: conn} do
      device_id = Ecto.UUID.generate()

      first = conn |> post(~p"/api/sessions/guest", device_id: device_id) |> json_response(200)

      second =
        build_conn() |> post(~p"/api/sessions/guest", device_id: device_id) |> json_response(200)

      assert first["account"]["id"] == second["account"]["id"]
      assert first["access_token"] != second["access_token"]
      assert Repo.aggregate(Account, :count) == 1
    end

    test "422 without a device_id", %{conn: conn} do
      assert %{"errors" => %{"device_id" => ["can't be blank"]}} =
               conn |> post(~p"/api/sessions/guest", %{}) |> json_response(422)
    end

    test "422 for a device_id that isn't a UUID", %{conn: conn} do
      assert %{"errors" => %{"device_id" => ["is invalid"]}} =
               conn |> post(~p"/api/sessions/guest", device_id: "nope") |> json_response(422)
    end
  end

  describe "POST /api/sessions/apple" do
    test "creates an Apple account from a verified token", %{conn: conn} do
      token = identity_token(%{"sub" => "apple-ada", "email" => "ada@privaterelay.appleid.com"})

      params =
        apple_params(%{"identity_token" => token, "given_name" => "Ada", "email" => "x@y.z"})

      assert %{
               "access_token" => session_token,
               "account" => %{
                 "id" => id,
                 "kind" => "apple",
                 "email" => "ada@privaterelay.appleid.com"
               }
             } = conn |> post(~p"/api/sessions/apple", params) |> json_response(200)

      assert %Account{id: ^id, apple_sub: "apple-ada", given_name: "Ada"} =
               Accounts.get_account_by_token(session_token)
    end

    test "uses the app's email when the token has none", %{conn: conn} do
      params = apple_params(%{"email" => "ada@example.com"})

      assert %{"account" => %{"email" => "ada@example.com"}} =
               conn |> post(~p"/api/sessions/apple", params) |> json_response(200)
    end

    test "returns the existing account for the same Apple sub", %{conn: conn} do
      params = apple_params(%{"identity_token" => identity_token(%{"sub" => "apple-ada"})})
      first = conn |> post(~p"/api/sessions/apple", params) |> json_response(200)

      params = apple_params(%{"identity_token" => identity_token(%{"sub" => "apple-ada"})})
      second = build_conn() |> post(~p"/api/sessions/apple", params) |> json_response(200)

      assert first["account"]["id"] == second["account"]["id"]
    end

    test "takes over the device's guest account", %{conn: conn} do
      device_id = Ecto.UUID.generate()

      %{"access_token" => guest_token, "account" => %{"id" => guest_id}} =
        conn |> post(~p"/api/sessions/guest", device_id: device_id) |> json_response(200)

      params = apple_params(%{"device_id" => device_id})

      assert %{"account" => %{"id" => ^guest_id, "kind" => "apple"}} =
               build_conn() |> post(~p"/api/sessions/apple", params) |> json_response(200)

      assert %Account{kind: :apple, device_id: nil} = Accounts.get_account_by_token(guest_token)

      # The device starts a fresh guest if the person later tries without an account again.
      assert %{"account" => %{"id" => new_guest_id}} =
               build_conn()
               |> post(~p"/api/sessions/guest", device_id: device_id)
               |> json_response(200)

      assert new_guest_id != guest_id
    end

    test "merges the device's guest into an existing Apple account", %{conn: conn} do
      params = apple_params(%{"identity_token" => identity_token(%{"sub" => "apple-ada"})})

      %{"account" => %{"id" => apple_id}} =
        conn |> post(~p"/api/sessions/apple", params) |> json_response(200)

      device_id = Ecto.UUID.generate()

      %{"access_token" => guest_token, "account" => %{"id" => guest_id}} =
        build_conn() |> post(~p"/api/sessions/guest", device_id: device_id) |> json_response(200)

      params =
        apple_params(%{
          "device_id" => device_id,
          "identity_token" => identity_token(%{"sub" => "apple-ada"})
        })

      assert %{"account" => %{"id" => ^apple_id}} =
               build_conn() |> post(~p"/api/sessions/apple", params) |> json_response(200)

      refute Repo.get(Account, guest_id)
      refute Accounts.get_account_by_token(guest_token)
    end

    test "401 for a token signed with another key", %{conn: conn} do
      params = apple_params(%{"identity_token" => identity_token(%{}, key: other_private_key())})

      assert %{"errors" => %{"detail" => "Unauthorized"}} =
               conn |> post(~p"/api/sessions/apple", params) |> json_response(401)

      assert Repo.aggregate(Account, :count) == 0
    end

    test "401 for a token issued to another app", %{conn: conn} do
      params =
        apple_params(%{"identity_token" => identity_token(%{"aud" => "com.example.other"})})

      assert conn |> post(~p"/api/sessions/apple", params) |> json_response(401)
    end

    test "401 for a token that isn't a JWT", %{conn: conn} do
      params = apple_params(%{"identity_token" => "not-a-jwt"})
      assert conn |> post(~p"/api/sessions/apple", params) |> json_response(401)
    end

    test "503 when Apple's keys can't be fetched", %{conn: conn} do
      Later.AppleKeysStub.unavailable()

      assert %{"errors" => %{"detail" => "Service Unavailable"}} =
               conn |> post(~p"/api/sessions/apple", apple_params()) |> json_response(503)
    end

    test "422 for missing fields", %{conn: conn} do
      assert %{
               "errors" => %{
                 "device_id" => ["can't be blank"],
                 "identity_token" => ["can't be blank"],
                 "authorization_code" => ["can't be blank"]
               }
             } = conn |> post(~p"/api/sessions/apple", %{}) |> json_response(422)
    end

    test "422 for an invalid device_id, before verifying the token", %{conn: conn} do
      params = apple_params(%{"device_id" => "nope", "identity_token" => "not-a-jwt"})

      assert %{"errors" => %{"device_id" => ["is invalid"]}} =
               conn |> post(~p"/api/sessions/apple", params) |> json_response(422)
    end
  end

  describe "POST /api/sessions/refresh" do
    setup %{conn: conn} do
      session =
        conn
        |> post(~p"/api/sessions/guest", device_id: Ecto.UUID.generate())
        |> json_response(200)

      %{session: session}
    end

    test "returns new tokens for the same account", %{session: session} do
      assert %{
               "access_token" => access_token,
               "refresh_token" => refresh_token,
               "expires_at" => _expires_at,
               "account" => %{"id" => id}
             } =
               build_conn()
               |> post(~p"/api/sessions/refresh", refresh_token: session["refresh_token"])
               |> json_response(200)

      assert id == session["account"]["id"]
      assert access_token != session["access_token"]
      assert refresh_token != session["refresh_token"]
      assert %Account{id: ^id} = Accounts.get_account_by_token(access_token)
      refute Accounts.get_account_by_token(session["access_token"])
      assert Repo.aggregate(SessionToken, :count) == 1
    end

    test "401 for a refresh token that was already used", %{session: session} do
      refresh = fn token ->
        post(build_conn(), ~p"/api/sessions/refresh", refresh_token: token)
      end

      assert %{"refresh_token" => new_token} =
               refresh.(session["refresh_token"]) |> json_response(200)

      assert %{"errors" => %{"detail" => "Unauthorized"}} =
               refresh.(session["refresh_token"]) |> json_response(401)

      assert refresh.(new_token) |> json_response(200)
    end

    test "401 for an expired refresh token", %{session: session} do
      Repo.update_all(SessionToken, set: [refresh_expires_at: ~U[2026-01-01 00:00:00Z]])

      assert build_conn()
             |> post(~p"/api/sessions/refresh", refresh_token: session["refresh_token"])
             |> json_response(401)
    end

    test "renews an expired access token", %{session: session} do
      Repo.update_all(SessionToken, set: [access_expires_at: ~U[2026-01-01 00:00:00Z]])
      refute Accounts.get_account_by_token(session["access_token"])

      assert %{"access_token" => access_token} =
               build_conn()
               |> post(~p"/api/sessions/refresh", refresh_token: session["refresh_token"])
               |> json_response(200)

      assert Accounts.get_account_by_token(access_token)
    end

    test "401 for an unknown refresh token", %{conn: conn} do
      assert conn |> post(~p"/api/sessions/refresh", refresh_token: "nope") |> json_response(401)
    end

    test "422 without a refresh_token", %{conn: conn} do
      assert %{"errors" => %{"refresh_token" => ["can't be blank"]}} =
               conn |> post(~p"/api/sessions/refresh", %{}) |> json_response(422)
    end
  end
end
