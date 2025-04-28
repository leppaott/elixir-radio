defmodule ElixirRadio.Repo do
  use Ecto.Repo,
    otp_app: :elixir_radio,
    adapter: Ecto.Adapters.Postgres
end
