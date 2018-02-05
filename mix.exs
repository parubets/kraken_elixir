defmodule KrakenElixir.Mixfile do
  use Mix.Project

  def project do
    [app: :kraken_elixir,
     version: "0.3.2",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     elixirc_options: [debug_info: false]]
  end

  def application do
    [
      applications: [:httpoison],
      mod: {KrakenElixir, []}
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:poison, "~> 3.1"},
    ]
  end
end
