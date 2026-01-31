import Config

config :elixir_radio, ElixirRadio.Repo,
  database: "elixir_radio",
  username: "postgres",
  password: "postgres",
  hostname: "postgres"

config :elixir_radio, ecto_repos: [ElixirRadio.Repo]

# Oban configuration (can be overridden in env configs)
config :elixir_radio, Oban,
  repo: ElixirRadio.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [audio_processing: 3, default: 5]

# Import environment specific config at the end
if File.exists?("config/#{config_env()}.exs") do
  import_config "#{config_env()}.exs"
end
