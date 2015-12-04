defmodule KrakenElixir.Mixfile do
  use Mix.Project

  def project do
    [app: :kraken_elixir,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [
      applications: [:httpotion],
      mod: {KrakenElixir, []}
    ]
  end

  defp deps do
    [
      {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.2.2"},
      {:httpotion, "~> 2.1.0"},
      {:poison, "~> 1.5"}
    ]
  end
end
