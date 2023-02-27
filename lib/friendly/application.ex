defmodule Friendly.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FriendlyWeb.Telemetry,
      Friendly.Repo,
      {Phoenix.PubSub, name: Friendly.PubSub},
      FriendlyWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Friendly.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    FriendlyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
