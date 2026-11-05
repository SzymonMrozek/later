defmodule LaterWeb.Router do
  use LaterWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", LaterWeb do
    pipe_through :api

    get "/health", HealthController, :show

    post "/sessions/guest", SessionController, :guest
    post "/sessions/apple", SessionController, :apple
    post "/sessions/refresh", SessionController, :refresh
  end
end
