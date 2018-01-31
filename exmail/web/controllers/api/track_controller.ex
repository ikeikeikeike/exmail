defmodule Exmail.Api.TrackController do
  @moduledoc """
  TODO: Currently, stil haven't made.

  1. These endpoints have to port to Golang system or OpenResty(Redis) system someday.

  2. 'open and click' params have to consider to make alternative name
     that's like hash in per campaign which have open,click,etc.. status.

  3. 'campaign and email' param must make alternative name for hard to think Campaign to expect by user.

  4. There's still remaining problem, which EXMAIL stores parameter into redis as a defective hash. like this.
       https://dl.dropboxusercontent.com/spa/ohj2tplmz3dn81a/010wxbl7.png

  """
  use Exmail.Web, :api

  import Exmail.Detector.Primitives, only: [numeric?: 1]

  alias Exmail.{Hash, Redis, Plug.Exceptions}

  # Assigns(Filters), which have to have simple validators.
  plug :filter_open when action in [:open]
  plug :assign_campaign
  plug :assign_email
  plug :assign_ipaddr
  plug :assign_headers

  defp filter_open(%Plug.Conn{req_headers: _} = conn, _opts) do
    accept   = get_req_header conn, "accept"
    encoding = get_req_header conn, "accept-encoding"

    cond do
      length(accept) <= 0 and length(encoding) <= 0 ->
        raise Exceptions.Invalid403Error, message: accept
      false ->    # not String.contains?(hd(accept), "image") ->
        raise "n/a" # raise Exceptions.Invalid403Error
      true ->
        conn
    end
  end

  defp assign_campaign(%Plug.Conn{params: params} = conn, _opts) do
    campaign_id = Hash.unmailify params["campaign"]

    (campaign_id || "")
    |> numeric?
    |> case do
      false ->
        raise Exceptions.InvalidCampaignTokenError, message: campaign_id
      _     ->
        %{conn | params: Map.put(params, "campaign_id", campaign_id)}
    end
  end

  defp assign_email(%Plug.Conn{params: params} = conn, _opts) do
    email = Hash.unmailify params["email"]

    (email || "")
    |> String.contains?("@")
    |> case do
      false ->
        raise Exceptions.InvalidEmailTokenError, message: email
      _     ->
        %{conn | params: Map.put(params, "emailaddr", email)}
    end
  end

  defp assign_ipaddr(%Plug.Conn{params: params} = conn, _opts) do
    remote_ip =
      conn.remote_ip
      |> Tuple.to_list
      |> Enum.join(".")

    xff_ip =
      conn
      |> get_req_header("x-forwarded-for")
      |> List.first

    overwrite = %{"xff_ip" => xff_ip, "remote_ip" => remote_ip}
    %{conn | params: Map.merge(params, overwrite)}
  end

  defp assign_headers(%Plug.Conn{params: params} = conn, _opts) do
    overwrite = Map.merge params, Map.new(conn.req_headers)
    %{conn | params: overwrite}
  end

  def open(conn, %{"campaign" => campaign} = params) do
    Redis.Track.push_open campaign, params

    conn
    |> put_resp_content_type("image/png")
    |> send_resp(200, fallback_image())
  end

  def html_click(conn, %{"campaign" => campaign, "l" => location} = params) do
    Redis.Track.push_html_click campaign, params

    conn
    |> redirect(external: location)
  end

  def text_click(conn, %{"campaign" => campaign, "l" => location} = params) do
    Redis.Track.push_text_click campaign, params

    conn
    |> redirect(external: location)
  end

end
