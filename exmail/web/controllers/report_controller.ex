defmodule Exmail.ReportController do
  use Exmail.Web, :controller

  import Exmail.Func, only: [fint!: 1]

  alias Exmail.{Report, Activity, AudienceSubscriber}

  @actions ~w(
    overview view_email
    activity_sent activity_open activity_click activity_bounce
    activity_open_subscriber activity_click_subscriber
    links
  )a

  plug Exmail.Plug.CurrentUser
  plug :assign_report when action in @actions
  plug :assign_switcher when action in @actions
  plug :assign_subscriber when action in [:activity_open_subscriber, :activity_click_subscriber]

  defp assign_report(%Plug.Conn{params: %{"report_id" => report_id}} = conn, _opts) do
    queryable =
      from q in Report.with_types(Report.with_summary),
        where: q.id == ^fint!(report_id)
           and q.user_id == ^(conn.assigns.current_user.id)
    conn
    |> assign(:report, Repo.one!(queryable))
  end

  defp assign_subscriber(%Plug.Conn{params: %{"audience_id" => audience_id, "subscriber_id" => subscriber_id}} = conn, _opts) do
    queryable = from q in AudienceSubscriber,
         join: j in assoc(q, :audience),
        where: q.audience_id == ^fint!(audience_id)
           and q.subscriber_id == ^fint!(subscriber_id)
           and j.user_id == ^(conn.assigns.current_user.id)
    conn
    |> assign(:subscriber, Repo.one!(queryable))
  end

  defp assign_switcher(conn, _opts) do
    switchers =
      from q in Report,
        where: q.user_id == ^(conn.assigns.current_user.id),
        order_by: [desc: q.id], limit: 8,
        preload: :campaign

    assign conn, :switchers, Repo.all(switchers)
  end

  def index(conn, params, current_user, _claims) do
    reports =
      from(q in Report,
        where: q.user_id == ^(current_user.id),
        order_by: [desc: q.id],
        preload: [:user, campaign: [:audience]]
      )
      |> Repo.paginate(params)

    render conn, "index.html", reports: reports
  end

  @doc """

  ## This is sample which Ecto issues aggregation query below. There's having a readability so much.

     SELECT s0.`status`, sum(s0.`count`)
     FROM (SELECT a0.`status` AS `status`, count(a0.`status`) AS `count`
             FROM `activities` AS a0
             WHERE ((a0.`report_id` = ?) AND a0.`status` IN (?,?,?))
             GROUP BY a0.`status`, a0.`subscriber_id`)
     AS s0 GROUP BY s0.`status` [5, 1, 2, 3]

  """
  def overview(%{assigns: %{report: r}} = conn, _params, _current_user, _claims) do
    # status base
    #
    #
    statuses  = ~w(open click soft_bounce hard_bounce)a
    base      =
      from q in Activity,
        group_by: [q.status, q.subscriber_id],
        where: q.report_id == ^(r.id)
           and q.status in ^statuses

    # total stats
    #
    queryable = from q in base, select: %{status: q.status, count: count(q.status)}
    queryable =
      from q in subquery(queryable),
        group_by: q.status,
        select: {q.status, sum(q.count)}
    stats_total =
      Map.new(Repo.all(queryable))
    # per user stats
    #
    queryable = from q in base, select: %{status: q.status}
    queryable =
      from q in subquery(queryable),
        group_by: q.status,
        select: {q.status, count(q.status)}
    stats_per_user =
      Map.new(Repo.all(queryable))

    # links base
    #
    #
    queryable = from q in Activity.aggs_total_links(r.id), limit: 5
    links_total = Map.new(Repo.all(queryable))

    # most open and click
    #
    #
    base = Activity.aggs_mostly(r.id)
    users_mostly = %{
      open: Repo.all(from [q, j] in base, where: q.status == ^:open),
      click: Repo.all(from [q, j] in base, where: q.status == ^:click),  # TODO:
    }

    render conn, "overview.html",
      stats_total: stats_total,
      stats_per_user: stats_per_user,
      links_total: links_total,
      users_mostly: users_mostly
      # links_per_user: links_per_user
  end

  def view_email(%{assigns: %{report: _r}} = conn, _params, _current_user, _claims) do
    render conn, "view_email.html"
  end

  def activity_sent(%{assigns: %{report: r}} = conn, params, _current_user, _claims) do
    queryable =
      from q in Activity.with_subscriber,
        where: q.report_id == ^(r.id)
          and  q.status    == ^:sent,
        order_by: :id

    render conn, "activity_sent.html", activities: Repo.paginate(queryable, params)
  end

  def activity_open(%{assigns: %{report: r}} = conn, _params, _current_user, _claims) do
    queryable =
      from q in Activity.aggs_status,
        where: q.report_id == ^(r.id)
           and q.status    == ^:open

    render conn, "activity_open.html", activities: load_activity(queryable)
  end

  def activity_open_subscriber(%{assigns: %{report: r}} = conn, %{"subscriber_id" => subscriber_id}, _current_user, _claims) do
    queryable =
      from q in Activity.with_activity,
        where: q.report_id == ^(r.id)
           and q.subscriber_id == ^fint!(subscriber_id)
           and q.status    == ^:open,
        order_by: :id

    render conn, "activity_open_subscriber.html", activities: Repo.all(queryable)
  end

  def activity_click(%{assigns: %{report: r}} = conn, _params, _current_user, _claims) do
    queryable =
      from q in Activity.aggs_status,
        where: q.report_id == ^(r.id)
           and q.status    == ^:click

    render conn, "activity_click.html", activities: load_activity(queryable)
  end

  def activity_click_subscriber(%{assigns: %{report: r}} = conn, %{"subscriber_id" => subscriber_id}, _current_user, _claims) do
    queryable =
      from q in Activity.with_activity,
        where: q.report_id == ^(r.id)
           and q.subscriber_id == ^fint!(subscriber_id)
           and q.status    == ^:click,
        order_by: :id

    render conn, "activity_click_subscriber.html", activities: Repo.all(queryable)
  end

  def activity_bounce(%{assigns: %{report: r}} = conn, _params, _current_user, _claims) do
    queryable =
      from q in Activity.aggs_status,
        where: q.report_id == ^(r.id)
          and (q.status == ^:hard_bounce or q.status == ^:soft_bounce)

    render conn, "activity_bounce.html", activities: load_activity(queryable)
  end

  def links(%{assigns: %{report: r}} = conn, _params, _current_user, _claims) do
    queryable = Activity.aggs_total_links r.id
    total     = Map.new Repo.all(queryable)

    render conn, "links.html", total: total
  end

  defp load_activity(queryable) do
    Repo.all(queryable)   # Repo.paginate(queryable, params)
    |> Enum.map(&struct Activity, &1)
    |> Repo.preload(:subscriber)
  end

end
