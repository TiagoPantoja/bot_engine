# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :bot_engine,
  ecto_repos: [BotEngine.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

config :bot_engine, Oban,
  repo: BotEngine.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [webhooks: 10]

# Configure the endpoint
config :bot_engine, BotEngineWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: BotEngineWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: BotEngine.PubSub,
  live_view: [signing_salt: "UVP34xqf"]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
