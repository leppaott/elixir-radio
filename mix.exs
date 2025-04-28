defmodule ElixirRadio.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_radio,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:bandit, "~> 1.0"},
      {:plug, "~> 1.14"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, "~> 0.20.0"},
      {:jason, "~> 1.0"}
    ]
  end
end
