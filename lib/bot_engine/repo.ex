defmodule BotEngine.Repo do
  use Ecto.Repo,
    otp_app: :bot_engine,
    adapter: Ecto.Adapters.Postgres
end
