import Config

# Increase pool size for handling concurrent segment streaming requests
# With ETS caching, most requests won't hit DB, but pool should handle bursts
config :elixir_radio, ElixirRadio.Repo, pool_size: 25
