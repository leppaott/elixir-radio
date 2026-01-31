# Start testcontainers
{:ok, _} = Testcontainers.start_link()

# Configure and start Postgres container with postgres:17-alpine
postgres_config =
  Testcontainers.PostgresContainer.new()
  |> Testcontainers.PostgresContainer.with_image("postgres:17-alpine")
  |> Testcontainers.PostgresContainer.with_user("postgres")
  |> Testcontainers.PostgresContainer.with_password("postgres")
  |> Testcontainers.PostgresContainer.with_database("elixir_radio_test")

{:ok, container} = Testcontainers.start_container(postgres_config)

# Configure database connection with container details
db_config = [
  database: "elixir_radio_test",
  username: "postgres",
  password: "postgres",
  hostname: Testcontainers.get_host(),
  port: Testcontainers.PostgresContainer.port(container),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10
]

Application.put_env(:elixir_radio, ElixirRadio.Repo, db_config)

# Start just the repo (if not already started)
Application.ensure_all_started(:postgrex)
Application.ensure_all_started(:ecto_sql)

case ElixirRadio.Repo.start_link(db_config) do
  {:ok, _} -> :ok
  {:error, {:already_started, _}} -> :ok
end

# Run migrations
path = Application.app_dir(:elixir_radio, "priv/repo/migrations")
Ecto.Migrator.run(ElixirRadio.Repo, path, :up, all: true)

# Set up Sandbox for tests
Ecto.Adapters.SQL.Sandbox.mode(ElixirRadio.Repo, :manual)

# Start Oban in test mode for integration tests
{:ok, oban_pid} = Oban.start_link(Application.fetch_env!(:elixir_radio, Oban))

# Configure Logger to suppress noisy test output
# Set to :error level to only show critical failures
Logger.configure(level: :error)

# Load support files before ExUnit starts
Code.require_file("support/data_case.exs", __DIR__)
Code.require_file("support/conn_case.exs", __DIR__)
Code.require_file("support/factory.exs", __DIR__)

# Stop services and container on exit
ExUnit.after_suite(fn _ ->
  # Gracefully stop Oban before database shutdown
  if Process.alive?(oban_pid) do
    Supervisor.stop(oban_pid, :normal, 5000)
  end

  # Stop the Repo to close all database connections
  :ok = Supervisor.stop(ElixirRadio.Repo, :normal, 5000)

  # Give connections time to close gracefully
  Process.sleep(300)

  # Stop container
  Testcontainers.stop_container(container.container_id)
end)

ExUnit.start()
