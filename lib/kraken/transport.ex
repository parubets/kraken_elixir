defmodule Kraken.Api.Error do
  defexception [message: "Kraken API exception", body: nil, status_code: nil, headers: nil]
end

defmodule Kraken.Api.Transport do
  use GenServer

  @base_url "https://api.kraken.com"
  @kraken_key Application.get_env(:kraken_elixir, __MODULE__, []) |> Keyword.get(:key)
  @kraken_secret Application.get_env(:kraken_elixir, __MODULE__, []) |> Keyword.get(:secret)

  @default_get_recv_timeout 5_000
  @default_post_recv_timeout 5_000

  ## Public API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def post(method, params) do
    GenServer.call(Kraken.Api.PostTransport, {:post, method, params}, :infinity)
  end

  def get(path) do
    GenServer.call(Kraken.Api.GetTransport, {:get, path}, :infinity)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, []}
  end

  def handle_call({:post, method, params}, _from, state) do
    {body, signature} = get_api_params(method, params)
    url = @base_url <> method
    post_headers = %{"Content-Type" => "application/x-www-form-urlencoded", "API-Key" => get_kraken_key(), "API-Sign" => signature}
    opts = [recv_timeout: (config(:post_recv_timeout) || @default_post_recv_timeout)]
    case HTTPoison.post(url, body, post_headers, opts) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} ->
        reply = parse_res(body, headers)
        {:reply, reply, state}
      {:ok, %HTTPoison.Response{status_code: status_code, body: body, headers: headers}} ->
        {:reply, {:error, %Kraken.Api.Error{message: "Kraken POST API exception", body: body, status_code: status_code, headers: headers}}, state}
      {:error, e} ->
        {:reply, {:error, e}, state}
    end
  end

  def handle_call({:get, path}, from, state) do
    url = @base_url <> path
    opts = [recv_timeout: (config(:get_recv_timeout) || @default_get_recv_timeout)]
    me = self()
    Task.start fn ->
      reply = case HTTPoison.get(url, opts) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} ->
          parse_res(body, headers)
        {:ok, %HTTPoison.Response{status_code: status_code, body: body, headers: headers}} ->
          {:error, %Kraken.Api.Error{message: "Kraken GET API exception", body: body, status_code: status_code, headers: headers}}
        {:error, e} ->
          {:error, e}
      end
      send me, {:got_get, reply, from}
    end
    {:noreply, state}
  end

  def handle_info({:got_get, reply, from}, state) do
    GenServer.reply(from, reply)
    {:noreply, state}
  end

  defp parse_res(body, headers) do
    case get_header(headers, "Content-Type") do
      "application/json; charset=utf-8" ->
        json = parse_json(body)
        case json do
          %{"error" => [], "result" => result} when map_size(result) > 0 ->
            {:ok, result}
          %{"error" => error} when length(error) > 0 ->
            {:error, %Kraken.Api.Error{message: List.to_string(error)}}
          _ ->
            {:error, %Kraken.Api.Error{message: body}}
        end
      _ ->
        {:error, body}
    end
  end

  defp get_api_params(method, params) do
    nonce = generate_nonce()
    body = Map.merge(%{nonce: nonce}, params)
      |> URI.encode_query
    signature = generate_signature(nonce, body, method)
    {body, signature}
  end

  defp generate_nonce do
    Integer.to_string(:os.system_time(:milli_seconds)) <> "0"
  end

  defp generate_signature(nonce, body, method) do
    key = Base.decode64!(get_kraken_secret())
    message = generate_message(nonce, body, method)
    :crypto.hmac(:sha512, key, message)
      |> Base.encode64
  end

  defp generate_message(nonce, body, method) do
    digest = :crypto.hash(:sha256, nonce <> body)
    method <> digest
  end

  defp parse_json(body) do
    Poison.decode!(body)
  end

  defp get_header(headers, key) do
    headers
    |> Enum.filter(fn({k, _}) -> k == key end)
    |> hd
    |> elem(1)
  end

  defp get_kraken_key do
    vault_get_kv("kraken", "key") || config(:key) || System.get_env("KRAKEN_KEY") || @kraken_key
  end

  defp get_kraken_secret do
    vault_get_kv("kraken", "secret") || config(:secret) || System.get_env("KRAKEN_SECRET") || @kraken_secret
  end

  defp vault_get_kv(path, key) do
    case config(:vault_module) do
      nil -> nil
      vault_mod when is_atom(vault_mod) -> vault_mod.get_kv(path, key)
    end
  end

  defp config do
    Application.get_env(:kraken_elixir, __MODULE__, [])
  end

  defp config(key, default \\ nil) do
    Keyword.get(config(), key, default)
  end

end
