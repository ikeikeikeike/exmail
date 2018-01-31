defmodule Exmail.SubscriberController do
  use Exmail.Web, :controller

  import Exmail.Func, only: [fint!: 1]

  alias Exmail.{Audience, Subscriber, Activity, AudienceSubscriber, Service.Subscribers}

  plug Exmail.Plug.CurrentUser
  plug :assign_audience
  plug :assign_switcher when action in [:index, :new, :show, :show_activity]
  plug :assign_subscriber when action in [:show, :show_activity]
  plug :assign_arrowpager when action in [:show, :show_activity]

  defp assign_audience(%Plug.Conn{params: %{"audience_id" => audience_id}} = conn, _opts) do
    queryable =
      from q in Audience,
        where: q.id == ^fint!(audience_id)
           and q.user_id == ^(conn.assigns.current_user.id)

     assign conn, :audience, Repo.one!(queryable)
  end

  defp assign_switcher(%Plug.Conn{params: %{"audience_id" => audience_id}} = conn, _opts) do
    switchers =
      from q in Audience,
        where: q.id == ^fint!(audience_id)
           and q.user_id == ^(conn.assigns.current_user.id),
        order_by: [desc: q.id], limit: 8

    assign conn, :switchers, Repo.all(switchers)
  end

  defp assign_subscriber(%Plug.Conn{params: %{"audience_id" => audience_id, "subscriber_id" => subscriber_id}} = conn, _opts) do
    queryable =
      from q in AudienceSubscriber,
         join: j in assoc(q, :audience),
        where: q.subscriber_id == ^fint!(subscriber_id)
           and q.audience_id == ^fint!(audience_id)
           and j.user_id == ^(conn.assigns.current_user.id)

     assign conn, :subscriber, Repo.one!(queryable) |> Repo.preload(:subscriber)
  end

  defp assign_arrowpager(%Plug.Conn{params: %{"audience_id" => audience_id, "subscriber_id" => subscriber_id}} = conn, _opts) do
    prev =
      from q in AudienceSubscriber,
        join: j in assoc(q, :audience),
        where: q.subscriber_id < ^fint!(subscriber_id)
           and q.audience_id == ^fint!(audience_id)
           and j.user_id == ^(conn.assigns.current_user.id),
        order_by: [desc: :id], limit: 1

    next =
      from q in AudienceSubscriber,
        join: j in assoc(q, :audience),
        where: q.subscriber_id > ^fint!(subscriber_id)
           and q.audience_id == ^fint!(audience_id)
           and j.user_id == ^(conn.assigns.current_user.id),
        order_by: [:id], limit: 1

    conn
    |> assign(:pager_prev, Repo.one(prev))
    |> assign(:pager_next, Repo.one(next))
  end

  def index(conn, params, _current_user, _claims) do
    subscrivers =
      from(q in AudienceSubscriber,
        where: q.audience_id == ^(conn.assigns.audience.id),
        order_by: [desc: q.id]
      )
      |> Repo.paginate(params)

    render conn, "index.html", subscribers: subscrivers
  end

  def new(conn, _params, _current_user, _claims) do
    changeset = Subscriber.changeset(%Subscriber{})
    render conn, "new.html", changeset: changeset
  end

  def import(conn, %{"wizard" => "File"}, _current_user, _claims) do
    render conn, "import_csv.html"
  end

  def import(conn, %{"wizard" => "CutPaste"}, _current_user, _claims) do
    render conn, "import_cutpaste.html"
  end

  def import(conn, %{"wizard" => "Review"}, _current_user, _claims) do
    render conn, "import_review.html"
  end

  # gonna be making: https://dl.dropboxusercontent.com/spa/ohj2tplmz3dn81a/pm5r7o14.png
  def import(conn, %{"wizard" => "Ops"}, _current_user, _claims) do
    render conn, "import_ops.html"
  end

  # File upload default here
  #   http://www.phoenixframework.org/docs/file-uploads#section-configuring-upload-limits
  #
  def import(conn, %{"wizard" => "Save"} = params, _current_user, _claims) do
    csv     = params["csv"]
    chsets  = Subscriber.import_changeset Exmail.File.read(csv)
    ensured = Enum.filter(chsets, & &1.valid?)

    if length(ensured) > 0 do
      # Doesnt wait
      job = fn ->
        Enum.each ensured, fn changeset ->
          Subscribers.attend_audience conn, changeset.params
        end
      end
      spawn job

      path    = subscriber_path conn, :index, conn.assigns.audience
      message = gettext "Import accomplished. Saves `%{name}` successfully `%{score} lines` " <>
                        "added to your list right now, Please check it out later. ",
                          name: csv.filename, score: "#{length ensured}/#{length chsets}"
      conn
      |> put_flash(:info, message <> "<a href='#{path}'>Reload</a>")
      |> redirect(to: path)
    else
      message = gettext "Import all of failed. Doesn't save `%{name}` successfully `%{score} lines` ",
                          name: csv.filename, score: "#{length ensured}/#{length chsets}"
      conn
      |> put_flash(:error, message)
      |> render("import_review.html", chsets: chsets)
    end
  end

  def import(conn, _params, _current_user, _claims) do
    render conn, "import.html"
  end

  def sync(conn, %{"wizard" => "Calcifer"}, _current_user, _claims) do
    render conn, "sync_calcifer.html"
  end

  def sync(conn, %{"wizard" => "Save"} = _params, _current_user, _claims) do
    path    = subscriber_path conn, :index, conn.assigns.audience
    message = gettext "Synchronizing right now, aaaaaaa bbbbbb, "

    conn
    |> put_flash(:info, message <> "<a href='#{path}'> Confirm sync progress</a>")
    |> redirect(to: path)
  end

  def sync(conn, _params, _current_user, _claims) do
    render conn, "sync.html"
  end

  # XXX: No transaction, this is no reason
  def create(conn, %{"subscriber" => params}, _current_user, _claims) do
    case Subscribers.attend_audience(conn, params) do
      {:ok, subscriber} ->

        # TODO: below
        # path    = subscriber_path conn, :show, subscriber
        path    = ""
        message = gettext "Registers accomplished. %{email} was successfully " <>
                          "added to your list. ", email: subscriber.email
        conn
        |> put_flash(:info, message <> "<a href='#{path}'>#{gettext "View Profile"}.</a>")
        |> redirect(to: subscriber_path(conn, :new, conn.assigns.audience))

      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end

  def show(conn, %{}, _current_user, _claims) do
    render conn, "show.html"
  end

  def show_activity(conn, %{"audience_id" => audience_id, "subscriber_id" => subscriber_id}, _current_user, _claims) do
    queryable =
      from q in Activity.with_activity,
        where: q.audience_id   == ^fint!(audience_id)
           and q.subscriber_id == ^fint!(subscriber_id),
        order_by: :id

    render conn, "show_activity.html", activities: Repo.all(queryable)
  end

  def show_note(conn, %{}, _current_user, _claims) do
    render conn, "show_activity.html"
  end

  def delete_relation(conn, %{"ids" => ids}, _current_user, _claims) do
    aid = conn.assigns.audience.id

    ids
    |> Enum.map(&Repo.get_by!(AudienceSubscriber, [audience_id: aid, subscriber_id: &1]))
    |> Enum.each(&Repo.delete!/1)

    conn
    |> put_flash(:info, gettext("Subscribers deleted successfully."))
    |> redirect(to: subscriber_path(conn, :index, conn.assigns.audience))
  end

  def delete_relation(conn, params, _current_user, _claims) do
    case params do
      %{"id" => id} ->
        aid       = conn.assigns.audience.id
        rel_child = Repo.get_by!(AudienceSubscriber, [audience_id: aid, subscriber_id: id])

        # Here we use delete! (with a bang) because we expect
        # it to always work (and if it does not, it will raise).
        Repo.delete! rel_child

        conn
        |> put_flash(:info, gettext("Subscriber deleted successfully."))
        |> redirect(to: subscriber_path(conn, :index, conn.assigns.audience))

      _ ->
        conn
        |> put_flash(:error, gettext("Subscriber deleted failure."))
        |> redirect(to: subscriber_path(conn, :index, conn.assigns.audience))
    end
  end

end
