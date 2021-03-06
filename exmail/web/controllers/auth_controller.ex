defmodule Exmail.AuthController do
  use Exmail.Web, :controller

  alias Exmail.UserFromAuth

  plug Ueberauth

  def login(conn, _params, current_user, _claims) do
    render conn, "login.html", current_user: current_user, current_auths: auths(current_user)
  end

  def callback(%Plug.Conn{assigns: %{ueberauth_failure: fails}} = conn, _params, current_user, _claims) do
    conn
    |> put_flash(:error, hd(fails.errors).message)
    |> render("login.html", current_user: current_user, current_auths: auths(current_user))
  end

  def callback(%Plug.Conn{assigns: %{ueberauth_auth: auth}} = conn, _params, current_user, _claims) do
    case UserFromAuth.get_or_insert(auth, current_user, Repo) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("Signed in as %{id}", id: user.email))
        |> Guardian.Plug.sign_in(user, :token, perms: %{default: Guardian.Permissions.max})
        |> redirect(to: page_path(conn, :index))
      {:error, reason} ->
        conn
        |> put_flash(:error, gettext("Could not authenticate: %{reason}", reason: reason))
        |> render("login.html", current_user: current_user, current_auths: auths(current_user))
    end
  end

  def credentials(conn, _, nil, _) do
    conn
    |> put_status(401)
    |> render("failed_credentials.json", error: gettext("not_authenticated"))
  end

  def credentials(conn, _params, current_user, {:ok, _claims}) do
    token = Guardian.Plug.current_token(conn)
    user  = %{name: current_user.email, email: current_user.email, id: current_user.id}
    render conn, "credentials.json", %{user: user, jwt: token}
  end

  def logout(conn, _params, current_user, _claims) do
    if current_user do
      conn
      # This clears the whole session.
      # We could use sign_out(:default) to just revoke this token
      # but I prefer to clear out the session. This means that because we
      # use tokens in two locations - :default and :admin - we need to load it (see above)
      |> Guardian.Plug.sign_out
      |> put_flash(:info, gettext("Signed out"))
      |> redirect(to: "/")
    else
      conn
      |> put_flash(:info, gettext("Not logged in"))
      |> redirect(to: "/")
    end
  end

  defp auths(nil), do: []
  defp auths(%Exmail.User{} = user) do
    Ecto.assoc(user, :authorizations)
      |> Repo.all
      |> Enum.map(&(&1.provider))
  end


end
