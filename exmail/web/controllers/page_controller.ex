defmodule Exmail.PageController do
  use Exmail.Web, :controller

  plug Exmail.Plug.CurrentUser

  def index(conn, _params, current_user, _claims) do
    render conn, "index.html", current_user: current_user
  end

end
