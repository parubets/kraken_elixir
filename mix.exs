defmodule KrakenElixir.Mixfile do
  use Mix.Project

  def project do
    [app: :kraken_elixir,
     version: "0.0.7",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [
      applications: [:httpoison],
      mod: {KrakenElixir, []}
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 0.8.2"},
      {:poison, "~> 2.1"}
    ]
  end
end
