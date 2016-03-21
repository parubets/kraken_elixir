defmodule KrakenElixirTest do
  use ExUnit.Case
  doctest KrakenElixir

  test "ticker good ticker" do
    {:ok, %{"XXBTZEUR" => price = %{}}} = Kraken.Api.ticker("XXBTZEUR")
    assert is_map(price) == true
    assert map_size(price) == 9
  end

  test "ticker wrong ticker" do
    {:error, %Kraken.Api.Error{message: message}} = Kraken.Api.ticker("XXBTZXXX")
    assert message == "EQuery:Unknown asset pair"
  end

end
