import Config

config :elixir_radio, ElixirRadio.Repo,
  database: "elixir_radio",
  username: "postgres",
  password: "postgres",
  hostname: "postgres"

config :elixir_radio, ecto_repos: [ElixirRadio.Repo]

if File.exists?("config/#{config_env()}.exs") do
  import_config "#{config_env()}.exs"
end
