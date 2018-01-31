defmodule Exmail.ErrorController do
  use Exmail.Web, :controller

  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, gettext("You must be logged in to access that page"))
    |> redirect(to: auth_path(conn, :login, "identity"))
  end
end
