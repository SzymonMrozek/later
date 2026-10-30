defmodule LaterWeb.HealthController do
  use LaterWeb, :controller

  # Used by the app, Fly.io checks and `mise run server:dev` smoke tests.
  def show(conn, _params) do
    json(conn, %{status: "ok", version: Application.spec(:later, :vsn) |> to_string()})
  end
end
