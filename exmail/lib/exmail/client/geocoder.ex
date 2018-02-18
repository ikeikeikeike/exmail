defmodule Exmail.Client.Geocoder do
  use HTTPoison.Base

  require Logger

  @endpoint "https://freegeoip.io/json/"

  def process_url(path) do
    Path.join @endpoint, path
  end

  def process_request_body(body) do
    case body do
      {:form, form} ->
        {:form, transform(form)}
      body ->
        body
    end
  end

  def process_request_options(options) do
    Keyword.merge options, [
      recv_timeout: 10_000, timeout: 10_000, follow_redirect: true
    ]
  end

  def process_response_body(body) do
    case Poison.decode body do
      {:ok,    body}        -> body
      {:error, body}        -> body
      {:error, :invalid, 0} -> body
    end
  end

  defp transform(payload) do
    for {k, v} <- payload, into: [], do: {:"#{k}", v}
  end

  def geocode(ipaddr) when is_binary(ipaddr) do
    case get ipaddr do
      {:ok, %{body: %{"latitude" => lat, "longitude" => lon} = body}}
          when is_number(lat) and is_number (lon) ->
        Map.put body, "latlon", "#{lat},#{lon}"

      {:ok, %{body: {:invalid, _}}} ->
        Logger.warn "Geocoder could not parse data on #{ipaddr}"

      msg ->
        Logger.warn "Geocoder error happened on #{inspect msg}"
    end
  end
  def geocode(_), do: nil

end
