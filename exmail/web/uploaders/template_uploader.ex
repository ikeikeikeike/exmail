defmodule Exmail.TemplateUploader do
  @moduledoc """
  TODO: It's gonna be required that needs to issue one time password using object storage is that
        secury for any user doesn't allow to refer html documents.
  """

  use Arc.Definition
  use Arc.Ecto.Definition
  use Exmail.BaseUploader

  alias Exmail.{Hash}

  require Logger

  @acl :public_read  # TODO: Authentication!
  @versions [:original, :screenshot]
  @extension_whitelist ~w(.html .htm .tpl .txt .text)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname |> String.downcase
    Enum.member?(@extension_whitelist, file_extension)
  end

  def transform(:screenshot, _) do
    conv = fn(input, output) ->
      src =
        if Path.extname(input) in @extension_whitelist do
          input
        else
          dst = Path.join(System.tmp_dir, "#{Hash.randstring(10)}.html")  # TODO: Support screenshot to text/plain, etc..
          File.copy input, dst
          dst
        end

      cmdopt = "--format jpg #{src} #{output}"
      Logger.debug fn ->
        "Generate screenshot to #{inspect __MODULE__}: wkhtmltoimage #{cmdopt}"
      end
      cmdopt
    end

    {:wkhtmltoimage, conv, :jpg}
  end

end
