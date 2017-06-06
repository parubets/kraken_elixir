defmodule KrakenElixir do
  use Application

  def start(_, _) do
    import Supervisor.Spec
    opts = [strategy: :one_for_one, name: KrakenElixir.Supervisor]
    Supervisor.start_link([
      worker(Kraken.Api.Transport, [[name: Kraken.Api.GetTransport]], id: :kraken_get),
      worker(Kraken.Api.Transport, [[name: Kraken.Api.PostTransport]], id: :kraken_post)
    ], opts)
  end
end
