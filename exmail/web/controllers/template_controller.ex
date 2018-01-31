defmodule Exmail.TemplateController do
  @moduledoc """
  TODO: Not yet make to render template from context data, like it does template engine.
  """
  use Exmail.Web, :controller

  import Exmail.Func, only: [fint!: 1]

  alias Exmail.{Template, Service, ImageUploader}

  plug Exmail.Plug.CurrentUser
  plug :assign_template when action in [:edit, :update, :upload]

  defp assign_template(%Plug.Conn{params: %{"id" => id}} = conn, _opts) do
    queryable =
      from q in Template,
        where: q.id == ^fint!(id)
           and q.user_id == ^(conn.assigns.current_user.id)
    conn
    |> assign(:template, Repo.one!(queryable))
  end

  def index(conn, params, current_user, _claims) do
    templates =
      from(q in Template,
        where: q.user_id == ^(current_user.id),
        order_by: [desc: q.id],
        preload: :user
      ) |> Repo.paginate(params)

    render conn, "index.html", templates: templates
  end

  def new(conn, _params, _current_user, _claims) do
    changeset = Template.changeset(%Template{})
    seeds     =
      from(q in Template, where: q.type == "Seeds")
      |> Repo.all

    conn
    |> put_layout("wider_app.html")
    |> render("new.html", changeset: changeset, seeds: seeds)
  end

  def create(conn, %{"tid" => tid} = params, current_user, _claims) do
    src    = Repo.get_by! Template, id: tid
    params = Map.merge params, %{"user_id" => current_user.id}

    case Service.Tpl.copy(src, params) do
      {:ok, template} ->
        conn
        |> redirect(to: template_path(conn, :edit, template))

      {:error, changeset} ->
        errors =
          changeset.errors
          |> Enum.map(fn {field, msg} ->
            "#{translate_default field} #{translate_error msg}"
          end)

        errors = Enum.join([gettext "Import HTML errors below:"] ++ errors, "<br />")
        conn
        |> put_flash(:error, errors)
        |> redirect(to: template_path(conn, :new))
    end
  end

  def import(conn, %{"template" => params}, current_user, _claims) do
    params = Map.merge params, %{"user_id" => current_user.id}

    case Service.Tpl.create(params) do
      {:ok, template} ->
        info = gettext("Sweet! You have exactly a brand new template.")

        conn
        |> put_flash(:info, info)
        |> redirect(to: template_path(conn, :edit, template))

      {:error, changeset} ->
        errors = translate_errors changeset
        errors = Enum.join([gettext "Import HTML errors below:"] ++ errors, "<br />")
        conn
        |> put_flash(:error, errors)
        |> redirect(to: template_path(conn, :new))
    end
  end

  def edit(%Plug.Conn{assigns: %{template: template}} = conn, %{"id" => _id}, _current_user, _claims) do
    conn
    |> put_layout("wizard_app.html")
    |> render("edit.html", changeset: Template.changeset(template))
  end

  def upload(%Plug.Conn{assigns: %{template: template}} = conn, %{"image" => datauri}, current_user, _claims) do
    params = %{"src" => datauri, "user_id" => current_user.id}

    Repo.transaction(fn ->
      with {:ok, image}     <- Service.Image.create(params),
           {:ok, _template} <- Repo.insert(Template.image_changeset(template, image)) do
        image
      else
        {:error, changeset} -> Repo.rollback changeset
      end
    end)
    |> case do
      {:ok, image} ->
        json conn, %{status: true, message: "ok", url: ImageUploader.develop_url({image.src, image})}

      {:error, changeset} ->
        errors = translate_errors(changeset) |> Enum.join("\n")
        json conn, %{status: false, message: errors}
    end
  end

  def update(%Plug.Conn{assigns: %{template: template}} = conn, %{"id" => _id, "body" => _body} = params, _current_user, _claims) do
    Service.Tpl.update_stored template, params
    json conn, %{msg: "ok"}
  end

end
