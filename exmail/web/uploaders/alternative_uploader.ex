defmodule Exmail.AlternativeUploader do
  @moduledoc """
  TODO: It's gonna be required that needs to issue one time password using object storage is that
        secury for any user doesn't allow to refer html documents.
  """

  use Arc.Definition
  use Arc.Ecto.Definition
  use Exmail.BaseUploader

  alias Exmail.{Hash}

  require Logger

  @acl :public_read  # TODO: change to one time password
  @versions [:original]
  @extension_whitelist ~w(.html .htm .tpl .txt .text)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname |> String.downcase
    Enum.member?(@extension_whitelist, file_extension)
  end

  def storage_dir(_version, {_file, model}) do
    dirname = Exmail.Func.thename model
    "uploads/alternative_#{dirname}/#{Hash.encrypt model.id}"
  end

  def transform(:original, {file, _scope}) do
    conv =
    fn(input, output) ->
      with {:ok, html}                 <- File.read(input),
           {:ok, pid} when is_pid(pid) <- File.open(output, [:write, :utf8]),
           [{"body", _, _} | _] = doc  <- Floki.find(html, "body") do
        Logger.debug fn -> "Generate fallback txt from #{inspect file}" end

        # Generate text to fallback HTML
        IO.write pid, doc |> Exmail.Markup.generate_text
      else
        [] ->
          # PlainText
          File.copy input, output

        error ->
          # Fallback for error
          Logger.warn "Could not make fallback txt: #{inspect error}"
          File.copy input, output
      end

      ""
    end

    {:echo, conv, :txt}
  end

end
