defmodule OgPreviewer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      OgPreviewerWeb.Telemetry,
      # Start the Ecto repository
      OgPreviewer.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: OgPreviewer.PubSub},
      # Start Finch
      {Finch, name: OgPreviewer.Finch},
      # Start the Endpoint (http/https)
      OgPreviewerWeb.Endpoint
      # Start a worker by calling: OgPreviewer.Worker.start_link(arg)
      # {OgPreviewer.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OgPreviewer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OgPreviewerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
