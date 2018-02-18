defmodule Exmail.Redis.Track do
  use Rdtype,
    uri: Application.get_env(:exmail, :redis)[:track],
    coder: Exmail.Redis.Json,
    type: :list

  alias Exmail.Hash

  @keys  ~w(open bounce html_click text_click)
  @keysa ~w(open bounce html_click text_click)a

  @spec push_open(String.t, map) :: String.t
  def push_open(hashkey, data) when is_binary(hashkey)  do
    data = Map.put(data, "status", "open")
    data = Map.put(data, "timestamp", :os.system_time(:millisecond))

    push track_key(hashkey, data), data
  end

  @spec push_open(any, map) :: String.t
  def push_open(key, data) do
    push_open Hash.mailify(key), data
  end

  @spec push_text_click(String.t, map) :: String.t
  def push_text_click(hashkey, data) when is_binary(hashkey)  do
    data = Map.put(data, "status", "text_click")
    data = Map.put(data, "timestamp", :os.system_time(:millisecond))

    push track_key(hashkey, data), data
  end

  @spec push_text_click(any, map) :: String.t
  def push_text_click(key, data) do
    push_text_click Hash.mailify(key), data
  end

  @spec push_html_click(String.t, map) :: String.t
  def push_html_click(hashkey, data) when is_binary(hashkey)  do
    data = Map.put(data, "status", "html_click")
    data = Map.put(data, "timestamp", :os.system_time(:millisecond))

    push track_key(hashkey, data), data
  end

  @spec push_html_click(any, map) :: String.t
  def push_html_click(key, data) do
    push_html_click Hash.mailify(key), data
  end

  @spec push_bounce(String.t, map) :: String.t
  def push_bounce(hashkey, data) when is_binary(hashkey) do
    data = Map.put(data, "status", "bounce")
    data = Map.put(data, "timestamp", :os.system_time(:millisecond))

    push track_key(hashkey, data), data
  end

  @spec push_bounce(any, map) :: String.t
  def push_bounce(key, data) do
    push_bounce Hash.mailify(key), data
  end

  @spec track_key(String.t, String.t|atom|map) :: String.t
  def track_key(id, %{"status" => status}) do
    track_key id, status
  end
  def track_key(id, status)
      when status in @keys
        or status in @keysa do
    "track:#{status}:#{id}"
  end

end
