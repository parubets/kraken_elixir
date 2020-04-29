defmodule KrakenElixir.Mixfile do
  use Mix.Project

  def project do
    [app: :kraken_elixir,
     version: "0.4.0",
     elixir: "~> 1.9",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     elixirc_options: [debug_info: false]]
  end

  def application do
    [
      extra_applications: [],
      mod: {KrakenElixir, []}
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.6"},
      {:poison, "~> 4.0"}
    ]
  end
end
