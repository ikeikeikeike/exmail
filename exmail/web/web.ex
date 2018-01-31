defmodule Exmail.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use Exmail.Web, :controller
      use Exmail.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      use Exmail.Schema
      use Chexes.Ecto

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Exmail.Gettext
      import Chexes
    end
  end

  def controller do
    quote do
      use Phoenix.Controller
      use Guardian.Phoenix.Controller
      alias Guardian.Plug.EnsureAuthenticated
      alias Guardian.Plug.EnsurePermissions

      alias Exmail.Repo
      import Ecto
      import Ecto.Query

      import Exmail.Router.Helpers
      import Exmail.Helpers
      import Exmail.ErrorHelpers
      import Exmail.Gettext
      import Chexes
    end
  end

  def api do
    quote do
      use Phoenix.Controller

      alias Exmail.Repo
      import Ecto
      import Ecto.Query

      import Exmail.Router.Helpers
      import Exmail.Helpers
      import Exmail.Gettext
      import Chexes
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]
      import Plug.Conn, only: [put_session: 3, get_session: 2, delete_session: 2, assign: 3]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML
      use Phoenix.HTML.SimplifiedHelpers

      alias Exmail.Repo
      import Ecto.Query

      import Exmail.Router.Helpers
      import Exmail.Helpers
      import Exmail.ErrorHelpers
      import Exmail.Gettext

      import Chexes
      # import CommonDeviceDetector.Detector
      import Scrivener.HTML
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias Exmail.Repo
      import Ecto
      import Ecto.Query
      import Exmail.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
