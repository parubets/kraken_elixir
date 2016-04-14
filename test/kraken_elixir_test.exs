defmodule KrakenElixirTest do
  use ExUnit.Case
  doctest KrakenElixir

  # Public API

  test "ticker good ticker" do
    {:ok, %{"XXBTZEUR" => price = %{}}} = Kraken.Api.ticker("XXBTZEUR")
    assert is_map(price) == true
    assert map_size(price) == 9
  end

  test "ticker wrong ticker" do
    {:error, %Kraken.Api.Error{message: message, body: body}} = Kraken.Api.ticker("XXBTZXXX")
    assert message == "EQuery:Unknown asset pair"
    assert body == nil
  end

  # Private API

  test "balance" do
    {:ok, balance} = Kraken.Api.balance
    assert is_map(balance) == true
    assert Map.has_key?(balance, "XXBT")
    assert Map.has_key?(balance, "ZEUR")
  end

end
