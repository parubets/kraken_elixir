defmodule Kraken.Api.Transport do
  use GenServer

  @base_url "https://api.kraken.com"

  ## Public API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def post(method, params) do
    GenServer.call(__MODULE__, {:post, method, params}, :infinity)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, []}
  end

  def handle_call({:post, method, params}, _from, state) do
    {body, signature} = get_api_params(method, params)
    url = @base_url <> method
    try do
      res = HTTPotion.post(url, [body: body, headers: ["Content-Type": "application/x-www-form-urlencoded", "API-Key": Application.get_env(:kraken_elixir, :key), "API-Sign": signature]])
      reply = parse_res(res)
      {:reply, reply, state}
    rescue
      e in HTTPotion.HTTPError -> {:reply, {:error, e}, state}
    end
  end

  defp parse_res(res) do
    case Keyword.fetch(res.headers, :"Content-Type") do
      {:ok, "application/json; charset=utf-8"} ->
        json = parse_json(res)
        case Map.fetch(json, "result") do
          {:ok, result} ->
            {:ok, result}
          :error ->
            error = Map.get(json, "error", []) |> List.to_string
            {:error, error}
        end
      {:ok, "text/html"} ->
        {:error, res.body}
      :error ->
        {:error, res.body}
    end
  end

  defp get_api_params(method, params) do
    nonce = generate_nonce
    body = Dict.merge(%{nonce: nonce}, params)
      |> URI.encode_query
    signature = generate_signature(nonce, body, method)
    {body, signature}
  end

  defp generate_nonce do
    Integer.to_string(:os.system_time(:milli_seconds)) <> "0"
  end

  defp generate_signature(nonce, body, method) do
    key = Base.decode64!(Application.get_env(:kraken_elixir, :secret))
    message = generate_message(nonce, body, method)
    :crypto.hmac(:sha512, key, message)
      |> Base.encode64
  end

  defp generate_message(nonce, body, method) do
    digest = :crypto.hash(:sha256, nonce <> body)
    method <> digest
  end

  defp parse_json(response) do
    Poison.decode!(response.body)
  end

end
