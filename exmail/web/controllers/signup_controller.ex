defmodule Exmail.SignupController do
  use Exmail.Web, :controller

  def new(conn, _params, current_user, _claims) do
    # ipaddr =
      # Tuple.to_list(conn.remote_ip)
      # |> Enum.join(".")

    if Application.get_env(:exmail, :env) == :prod do
      conn
      |> put_status(403)
      |> text("Forbidden")
    else
      render conn, "new.html", current_user: current_user
    end
  end
end
