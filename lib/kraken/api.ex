defmodule Kraken.Api do

  def balance do
    post_to_api "/0/private/Balance"
  end

  def trade_balance do
    post_to_api "/0/private/TradeBalance"
  end

  def open_orders(opts \\ []) do
    trades = Keyword.get(opts, :trades)
    userref = Keyword.get(opts, :userref)
    post_to_api "/0/private/OpenOrders", reduce_params(%{trades: trades, userref: userref})
  end

  def trade_volume(opts \\ []) do
    pair = Keyword.get(opts, :pair)
    post_to_api "/0/private/TradeVolume", reduce_params(%{pair: pair})
  end

  defp post_to_api(method, params \\ %{}) do
    Kraken.Api.Transport.post(method, params)
  end

  defp reduce_params(params_map) do
    for {k, v} <- params_map, v != nil, into: %{}, do: {k, v}
  end

end
