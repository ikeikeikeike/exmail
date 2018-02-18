defmodule Exmail.Tasks.Sendmail do

  import Ecto.Query
  import Exmail.Gettext
  import Exmail.Func, only: [fint!: 1]

  alias Exmail.{Repo, Emails, Campaign}

  require Logger

  # iex(95)> DateTime.from_unix 1450000000
  # {:ok, #<DateTime(2015-12-13T09:46:40Z Etc/UTC)>}
  @valid_unixtime 1_450_000_000

  @reservation_sec 75
  def reservation_sec, do: @reservation_sec

  @cancelable_sec 10
  def cancelable_sec, do: @cancelable_sec

  def cancelable(datetime) do
     diff = DateTime.to_unix(datetime) - DateTime.to_unix(DateTime.utc_now) + @reservation_sec
    {diff > @cancelable_sec, diff}
  end
  def cancelable?(nil),     do: false
  def cancelable?(datetime) do
    {boolean, _diff} = cancelable(datetime)
     boolean
  end

  def cancel(campaign, _params \\ %{}) do
    reltype = Campaign.reltype campaign
    params  = %{"schedule" => "cancel"}

    Repo.transaction(fn ->
      with {true, _diff} <- cancelable(reltype.schedule),
           {:ok, _report} <- Repo.delete(campaign.report),
           {:ok, %{campaign_id: _} = reltype} <- Repo.update(Campaign.schedule_changeset(campaign, params)) do
        {:ok, reltype}
      else
        {false, diff} ->
          Repo.rollback {:timeover, gettext("%{diff} seconds over", diff: diff)}
        error ->
          Repo.rollback error
      end
    end)
    |> case do
      {:ok, msg} -> msg
      {:error, error} -> error
    end
  end

  def reserve(campaign, %{"user_id" => _, "campaign_id" => _} = params) do
    case Repo.update(Campaign.schedule_changeset(campaign, params)) do
      {:ok, %{campaign_id: _} = reltype} = ok ->
        execution_time = DateTime.to_unix(reltype.schedule) - DateTime.to_unix(DateTime.utc_now)

        Exq.enqueue_in Exq, "default", execution_time + @reservation_sec, __MODULE__, [params]
        ok

      err ->
        err
    end
  end

  def perform(%{"user_id" => user_id, "campaign_id" => campaign_id}) do
    queryable =
      from [q, _j] in Campaign.with_reportable,
        where: q.id == ^fint!(campaign_id)
           and q.user_id == ^fint!(user_id)
    campaign =
      queryable
      |> Campaign.with_types
      |> Campaign.with_subscribers
      |> Repo.one!

    Application.ensure_all_started :ecto
    rel = Campaign.reltype campaign

    with s when not is_nil(s) and not is_binary(s) <- rel.schedule,
         unixtime when unixtime > @valid_unixtime <- DateTime.to_unix(s),
         # send email below.
         {:ok, msg} = ok <- Emails.Campaign.deliver(campaign, campaign.audience.subscribers) do

      Logger.info(inspect msg)
      ok
    else
      msg ->
        # TODO: Set sent flag into campaign table for make sure send-email.
        Logger.error("Email haven't send: #{inspect msg}")
    end
  rescue Ecto.NoResultsError ->
    "there's no sendable a record"
  end

end
