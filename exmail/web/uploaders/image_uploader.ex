defmodule Exmail.ImageUploader do
  use Arc.Definition
  use Arc.Ecto.Definition

  alias Exmail.{Hash}
  use Exmail.BaseUploader

  require Logger

  @acl :public_read
  @versions [:original]
  @extension_whitelist ~w(.png .gif .jpg .jpeg .bmp)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname |> String.downcase
    Enum.member?(@extension_whitelist, file_extension)
  end

  ### XXX: Below is working around that document uri needs to convert
  #        to shorten string for to read email by users with readability.
  #

  # XXX: To shorten url from over six hundred which is suquencial id
  @from_shorten 600
  defp latest_ver?(id) do
    __storage() == Arc.Storage.S3 and is_integer(id) and id > @from_shorten
  end

  def storage_dir(version, {file, %{id: id} = model}) do
    if latest_ver? id do
      "p-img/#{Hash.short id}"
    else
      super version, {file, model}
    end
  end

  def filename(version, {file, %{id: id} = model}) do
    if latest_ver? id do
      "#{Hash.short file.file_name}"
    else
      super version, {file, model}
    end
  end
  # XXX: End: workaround

end
