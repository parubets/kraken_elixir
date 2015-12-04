defmodule KrakenElixir do
  use Application

  def start(_, _) do
    import Supervisor.Spec
    opts = [strategy: :one_for_one, name: KrakenElixir.Supervisor]
    Supervisor.start_link([worker(Kraken.Api.Transport, [[name: Kraken.Api.Transport]])], opts)
  end
end
