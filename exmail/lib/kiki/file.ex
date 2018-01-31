defmodule Exmail.File do

  alias Exmail.{Hash}

  def read(%Plug.Upload{} = file) do
    case file do
      %{path: path, content_type: "text/csv"} ->
        File.stream!(path)
        |> CSV.decode

      %{path: path, content_type: "text/tab-separated-values"} ->
        File.stream!(path)
        |> CSV.decode(separator: ?\t)

      %{path: path} ->
        read path

      _ ->
        Stream.map [], & &1
    end
  end
  def read(path) when is_binary(path) do
    stream = File.stream! path
    cond do
      csv?(stream) ->
        CSV.decode stream

      tsv?(stream) ->
        CSV.decode stream, separator: ?\t

      true         ->
        Stream.map [], & &1
    end
  end

  # Comma separated
  def csv?(path) when is_binary(path) do
    csv? File.stream!(path)
  end
  def csv?(%File.Stream{} = fstream) do
    fstream
    |> CSV.decode
    |> separated?()
  end

  # Tab separated
  def tsv?(path) when is_binary(path) do
    tsv? File.stream!(path)
  end
  def tsv?(%File.Stream{} = fstream) do
    fstream
    |> CSV.decode(separator: ?\t)
    |> separated?()
  end

  # Take 3 lines and then make sure that a file ensures separated.
  defp separated?(%Stream{enum: enum} = stream)
       when is_list(enum) or is_function(enum) do
    result =
      stream
      |> Enum.take(3)
      |> Enum.filter(&length(&1) > 1)

    length(result) > 0
  rescue
    CSV.LineAggregator.CorruptStreamError ->
      false
  end
  defp separated?(_), do: false

  def store_temporary(data, opts \\ [])

  def store_temporary(data, [{:f, func} | opts]) when is_function(func) do
    fpath = store_temporary data, opts

    value = func.(fpath)
    File.rm fpath

    value
  end
  def store_temporary(data, opts) do
    decoder =
      case opts[:format] do
        :image -> &decode_datauri/1
        _      -> fn decoded ->
                    decoded
                  end
      end

    fpath = Path.join System.tmp_dir, Hash.randstring(10)
    File.write fpath, decoder.(data)
    fpath
  end

  def decode_datauri(datauri) do
    {_, "base" <> format, _, _, encoded} = parse_datauri datauri
    apply Base, :"decode#{format}!", [encoded]
  end

  def parse_datauri(datauri) do
    [headers, encoded] = String.split datauri, ","
    [header, format] = String.split headers, ";"
    ["data", mime] = String.split header, ":"
    ext = List.first MIME.extensions(mime)

    {headers, format, mime, ext, encoded}
  end

end
