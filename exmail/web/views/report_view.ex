defmodule Exmail.ReportView do
  use Exmail.Web, :view

  import Exmail.Func, only: [fint!: 1]

  alias Exmail.{Campaign, TemplateUploader, AlternativeUploader}

  def avg(numerator, denominator, de \\ 2) do
    Float.round (numerator || 0) / denominator * 100, de
  end

  def tidy_format(uri) do
    filename = Exmail.File.store_temporary codeable(uri)

    System.find_executable("tidy")
    |> System.cmd([
      "--indent", "auto", "--quiet", "yes",
      "--show-body-only", "yes",
      "--show-errors", "0",
      "--tidy-mark", "no",
      "--wrap", "0",
      filename,
    ])
    |> (case do
      {b, _} when is_binary(b) ->
        b
      _ ->
        "There is no Preview"
    end)
  end
end
