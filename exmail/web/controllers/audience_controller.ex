defmodule Exmail.AudienceController do
  use Exmail.Web, :controller

  import Exmail.Func, only: [fint!: 1]

  alias Exmail.Audience

  plug Exmail.Plug.CurrentUser
  plug :assign_audience when action in [:show, :edit, :update, :delete]
  plug :assign_switcher when action in [:show]

  defp assign_audience(%Plug.Conn{params: %{"id" => id}} = conn, _opts) do
    queryable =
      from q in Audience,
        where: q.id == ^fint!(id)
           and q.user_id == ^(conn.assigns.current_user.id),
        order_by: [desc: :id]

    assign conn, :audience, Repo.one!(queryable)
  end

  defp assign_switcher(%Plug.Conn{} = conn, _opts) do
    switchers =
      from q in Audience,
        where: q.user_id == ^(conn.assigns.current_user.id),
        order_by: [desc: q.id], limit: 8

    assign conn, :switchers, Repo.all(switchers)
  end

  def index(conn, params, current_user, _claims) do
    audiences =
      from(q in Audience, where: q.user_id == ^(current_user.id), order_by: [desc: :id])
      |> Repo.paginate(params)

    render(conn, "index.html", audiences: audiences)
  end

  def new(conn, _params, _current_user, _claims) do
    changeset = Audience.changeset(%Audience{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"audience" => params}, current_user, _claims) do
    params    = Map.merge(params, %{"user_id" => current_user.id})
    changeset = Audience.changeset(%Audience{}, params)

    case Repo.insert(changeset) do
      {:ok, audience} ->
        message = gettext("Sweet! You have exactly a brand new audience.")
        conn
        |> put_flash(:info, message)
        |> redirect(to: audience_path(conn, :show, audience))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(%Plug.Conn{assigns: %{audience: _audience}} = conn, %{"id" => _id}, _current_user, _claims) do
    render conn, "show.html"
  end

  def edit(%Plug.Conn{assigns: %{audience: audience}} = conn, %{"id" => _id}, _current_user, _claims) do
    render conn, "edit.html", changeset: Audience.changeset(audience)
  end

  def update(%Plug.Conn{assigns: %{audience: audience}} = conn, %{"id" => _id, "audience" => params}, _current_user, _claims) do
    audience
    |> Audience.changeset(params)
    |> Repo.update
    |> case do
      {:ok, audience} ->
        conn
        |> put_flash(:info, gettext("Audience updated successfully."))
        |> redirect(to: audience_path(conn, :show, audience))

      {:error, changeset} ->
        render conn, "edit.html", audience: audience, changeset: changeset
    end
  end

  def delete(%Plug.Conn{assigns: %{audience: audience}} = conn, %{"id" => _id}, _current_user, _claims) do
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete! audience

    conn
    |> put_flash(:info, gettext("Audience deleted successfully."))
    |> redirect(to: audience_path(conn, :index))
  end
end
