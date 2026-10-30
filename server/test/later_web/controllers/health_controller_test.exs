defmodule LaterWeb.HealthControllerTest do
  use LaterWeb.ConnCase, async: true

  test "GET /api/health", %{conn: conn} do
    assert %{"status" => "ok"} = conn |> get(~p"/api/health") |> json_response(200)
  end
end
