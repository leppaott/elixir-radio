import Config

config :elixir_radio, ElixirRadio.Repo,
  show_sensitive_data_on_connection_error: true,
  pool_size: 20

# Lettuce hot-reload configuration
config :lettuce,
  paths: ["lib/"],
  reload_on_save: true,
  on_reload: fn ->
    # Clear Cachex cache on hot-reload
    Cachex.clear(:segment_cache)
    IO.puts("Cachex cache cleared after reload")
  end
