defmodule Exmail.Plug.Exceptions do

  defmodule InvalidEmailTokenError do
    @moduledoc "Error raised when Email token is invalid."

    defexception [:message, :plug_status]

    def exception(opts) do
      message = Keyword.get(opts, :message, "unreached")
      status  = Keyword.get(opts, :plug_status, 403)
      message = """
      Invalid Email token '#{inspect message}':

      make sure all requests include a valid email param
      """

      %__MODULE__{message: message, plug_status: status}
    end
  end

  defmodule InvalidCampaignTokenError do
    @moduledoc "Error raised when Campaign token is invalid."

    defexception [:message, :plug_status]

    def exception(opts) do
      message = Keyword.get(opts, :message, "unreached")
      status  = Keyword.get(opts, :plug_status, 403)
      message = """
      Invalid Campaign token '#{inspect message}':

      make sure all requests include a valid Campaign param
      """

      %__MODULE__{message: message, plug_status: status}
    end
  end

  defmodule Invalid403Error do
    @moduledoc "Error raised when user has not request content for API"

    defexception [:message, :plug_status]

    def exception(opts) do
      message = Keyword.get(opts, :message, "unreached")
      status  = Keyword.get(opts, :plug_status, 403)
      message = """
      Invalid request '#{inspect message}':

      make sure all requests include a valid param
      """

      %__MODULE__{message: message, plug_status: status}
    end
  end

  defmodule NoContentError do
    @moduledoc "Error raised when user has not request content."

    defexception [:message, :plug_status]

    def exception(opts) do
      message = Keyword.get(opts, :message, "Not Found")
      status  = Keyword.get(opts, :plug_status, 404)
      message = """
      Invalid request '#{inspect message}':

      make sure all requests include a valid param
      """

      %__MODULE__{message: message, plug_status: status}
    end
  end
end
