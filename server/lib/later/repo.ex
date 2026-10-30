defmodule Later.Repo do
  use Ecto.Repo,
    otp_app: :later,
    adapter: Ecto.Adapters.Postgres
end
