defmodule Exmail.TemplateView do
  use Exmail.Web, :view

  alias Exmail.{Template, TemplateUploader}

  def tinyeditor_attributes(_conn, %Template{} = tpl) do
    attrs = ~w(
      data-tpl=#{TemplateUploader.url {tpl.tpl, tpl}}
    )

    attrs
    |> Enum.filter(& !!&1)
    |> Enum.join(" ")
  end

end
