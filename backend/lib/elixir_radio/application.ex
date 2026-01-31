defmodule ElixirRadio.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    import Cachex.Spec

    # Repo/Oban managed by test_helper in test env
    children =
      if Mix.env() == :test do
        [
          # Test: 150 entries (~30MB), LRW eviction
          {Cachex,
           name: :segment_cache,
           hooks: [
             hook(
               module: Cachex.Limit.Scheduled,
               args: {150, [reclaim: 0.1], [frequency: :timer.seconds(3)]}
             )
           ]}
        ]
      else
        [
          # Production: 1000 entries (~200MB), LRW eviction
          {Cachex,
           name: :segment_cache,
           hooks: [
             hook(
               module: Cachex.Limit.Scheduled,
               args: {1000, [reclaim: 0.1], [frequency: :timer.seconds(3)]}
             )
           ]},
          {ElixirRadio.Repo, []},
          {Oban, Application.fetch_env!(:elixir_radio, Oban)}
        ]
      end

    # Skip HTTP server in test unless explicitly enabled
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
