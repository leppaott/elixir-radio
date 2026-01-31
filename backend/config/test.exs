import Config

# Configure test database (will be overridden by test_helper with container details)
config :elixir_radio, ElixirRadio.Repo,
  database: "elixir_radio_test",
  username: "postgres",
  password: "postgres",
  hostname: System.get_env("DB_HOST", "localhost"),
  port: String.to_integer(System.get_env("DB_PORT", "5432")),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# Disable Oban in tests
config :elixir_radio, Oban, testing: :manual, queues: false, plugins: false

# Print only warnings and errors during test
config :logger, level: :warning

# Don't start the HTTP server in tests
config :elixir_radio, start_http: false
