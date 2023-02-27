defmodule Friendly.Repo do
  use Ecto.Repo,
    otp_app: :friendly,
    adapter: Ecto.Adapters.Postgres
end
