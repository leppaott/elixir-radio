defmodule ElixirRadio.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Database repo
      {ElixirRadio.Repo, []},

      # Start the Bandit server
      {Bandit, plug: ElixirRadio.StreamingServer, port: 4000}
    ]

    opts = [strategy: :one_for_one, name: ElixirRadio.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
