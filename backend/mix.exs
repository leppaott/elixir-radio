defmodule ElixirRadio.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_radio,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_pattern: "*_test.exs"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ElixirRadio.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bandit, "~> 1.6"},
      {:plug, "~> 1.17"},
      {:ecto_sql, "~> 3.12"},
      {:postgrex, "~> 0.20"},
      {:jason, "~> 1.4"},
      {:oban, "~> 2.20"},
      {:lettuce, "~> 0.3", only: :dev},
      {:testcontainers, "~> 1.10", only: :test}
    ]
  end
end
