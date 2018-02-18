defmodule Exmail.Tasks.AggsTracks do
  @moduledoc """
  Aggregate tracking logs' data that is received from API and SMTPServer
  """

  import Chexes, only: [present?: 1]

  alias Exmail.{Repo, Campaign, Activity, Hash, Redis, Client, Service}
  alias Exmail.{Activity.ActivityLink, Ecto.Q}

  require Logger

  @doc """
  This function is called from two ways that run as manually and as cron task.
  """
  def perform(campaign_id, type) do
    camp = Repo.get! Campaign.with_reportable, campaign_id
    update camp, type
  end
  def perform do
    campaigns = Repo.all Campaign.with_reportable

    Enum.each campaigns, fn camp ->
      update camp, :open
      update camp, :bounce
      update camp, :html_click
      update camp, :text_click
    end
  end

  def update(%Campaign{audience: %{subscribers: _}} = camp, type) do
    resource = make_resource camp, type

    Enum.each resource, fn {log, ausubs} ->
      if log do
        # Update subscriber profile
        #
        geocode = Client.Geocoder.geocode ipaddr(log)
        params  = %{
          mailer: mailer(log),
          language: language(log),
          latlon: latlon(geocode),
          timezone: timezone(geocode),
          bouncemsg: bouncemsg(log),
        }
        case Service.Subscribers.latest_update ausubs, params do
          {:error, chset} ->
            "could not latest update 'subscriber' with" <>
            " audience_id:#{ausubs.audience_id}" <>
            " subscriber_id:#{ausubs.subscriber_id}" <>
            " msg:#{inspect chset.errors}"
            |> Logger.error

          _ -> :none
        end
      end

      # Update activity log
      #
      params = %{
        report_id: camp.report.id,
        campaign_id: camp.id,
        audience_id: ausubs.audience_id,
        subscriber_id: ausubs.subscriber_id,
        activity_link_id: link_id(log),
        status: status(type, log),
        timestamp: timestamp(log),
      }
      chset = Activity.changeset %Activity{}, params
      case Repo.insert chset do
        {:error, chset} ->
          "could not insert log into 'activity' with" <>
          " audience_id:#{ausubs.audience_id}" <>
          " subscriber_id:#{ausubs.subscriber_id}" <>
          " msg:#{inspect chset.errors}"
          |> Logger.error

        _ -> :none
      end
    end
  end

  ## Both status html and text is using as click status
  #
  #  Bounce Data: http://libsisimai.org/en/data/
  #
  defp status(:bounce, %{"_bounce" => %{"softbounce" => 0}}), do: :hard_bounce
  defp status(:bounce, %{"_bounce" => %{"softbounce" => 1}}), do: :soft_bounce
  defp status(:bounce, _), do: :bounce  # Undetected
  defp status(:html_click, _), do: :click
  defp status(:text_click, _), do: :click
  defp status(type, _), do: type

  defp make_resource(camp, :sent) do
    Enum.map camp.audience.subscribers, fn ausub ->
      {nil, ausub}
    end
  end
  defp make_resource(camp, type) do
    ausubs = camp.audience.subscribers
    key    = Redis.Track.track_key Hash.mailify(camp.id), type

    resource =
      Enum.map tracklogs(key), fn log ->
        case Enum.filter ausubs, & "#{&1.email}" == "#{emailaddr(log)}" do
          [ausub] ->
            {log, ausub}
          _msg ->
            false
        end
      end

    Enum.filter resource, & !!&1
  end

  defp tracklogs(key) do
    logs = Redis.Track.lrange key, 0, -1
    if present?(logs), do: Redis.Track.del(key)
    Enum.sort logs, & &1["timestamp"] <= &2["timestamp"]  # Must be oldest order due to sequentially insert record to creation of datetime.
  end

  defp ipaddr(%{} = log) do
    log["x-real-ip"] || log["x-forwarded-for"] || log["remote_ip"]
  end
  defp ipaddr(_) do
    nil
  end

  defp link_id(%{"l" => l}) do
    case l && Q.get_or_create(%ActivityLink{}, %{link: l}) do
      {:ok,  alink} -> alink.id
      {:new, alink} -> alink.id
      _err          -> nil
    end
  end
  defp link_id(_) do
    nil
  end

  defp mailer(%{} = _log) do
    # TODO: http://stackoverflow.com/questions/4085332/email-client-detection
    #       https://www.cuenote.jp/glossary/mua.html
    "Not Implement"
  end
  defp mailer(_) do
    nil
  end

  defp language(%{} = log) do
    (log["accept-language"] || "UNKNOWN")
    |> String.split(",")
    |> List.first
  end
  defp language(_) do
    nil
  end

  defp timezone(%{} = geocode) do
    geocode["time_zone"]
  end
  defp timezone(_) do
    nil
  end

  defp latlon(%{} = geocode) do
    geocode["latlon"]
  end
  defp latlon(_) do
    nil
  end

  ## Both used that extract email-address from bounce or html,click,open status content.
  #
  defp emailaddr(%{"emailaddr" => emailaddr} = _log) do
    emailaddr
  end
  defp emailaddr(%{"X-Campaign" => hashedkey} = _log) do
    hashedkey
    |> Hash.unidify
    |> Enum.map(&Hash.unmailify/1)
    |> List.first
  end
  defp emailaddr(_) do
    nil
  end

  defp bouncemsg(%{"_bounce" => %{"reason" => msg}})
       when is_binary(msg) and byte_size(msg) > 0 do
    msg
  end
  defp bouncemsg(%{"_bounce" => %{"reason" => ""}}) do
    "UNKNOWN"
  end
  defp bouncemsg(_) do
    nil
  end

  defp timestamp(%{"timestamp" => timestamp}) do
    DateTime.from_unix! timestamp, :millisecond
  end
  defp timestamp(_) do
    DateTime.utc_now
  end

end
