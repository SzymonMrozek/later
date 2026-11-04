# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :later,
  ecto_repos: [Later.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Sign in with Apple identity tokens must be issued for this bundle ID.
config :later, :apple_bundle_id, "dev.mrozek.later"

# Configure the endpoint
config :later, LaterWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: LaterWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Later.PubSub,
  live_view: [signing_salt: "smwjAnzV"]

# Background jobs live in Postgres, so the app needs no Redis.
config :later, Oban,
  engine: Oban.Engines.Basic,
  repo: Later.Repo,
  queues: [default: 10]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
