defmodule ElixirRadio.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # In test, Repo and Oban are managed by test_helper
    children =
      if Mix.env() == :test do
        []
      else
        [
          # Database repo
          {ElixirRadio.Repo, []},

          # Oban for background jobs
          {Oban, Application.fetch_env!(:elixir_radio, Oban)}
        ]
      end

    # Only start HTTP server if not in test mode or explicitly disabled
    children =
      if Application.get_env(:elixir_radio, :start_http, true) do
        children ++ [{Bandit, plug: ElixirRadio.StreamingServer, port: 4000}]
      else
        children
      end

    opts = [strategy: :one_for_one, name: ElixirRadio.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
