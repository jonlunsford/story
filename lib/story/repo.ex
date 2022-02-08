defmodule Story.Repo do
  use Ecto.Repo,
    otp_app: :story,
    adapter: Ecto.Adapters.Postgres
end
