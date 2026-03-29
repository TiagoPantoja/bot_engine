defmodule BotEngine.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BotEngineWeb.Telemetry,
      BotEngine.Repo,
      {DNSCluster, query: Application.get_env(:bot_engine, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BotEngine.PubSub},
      {Oban, Application.fetch_env!(:bot_engine, Oban)},
      # Start a worker by calling: BotEngine.Worker.start_link(arg)
      # {BotEngine.Worker, arg},
      # Start to serve requests, typically the last entry
      BotEngineWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BotEngine.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BotEngineWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
