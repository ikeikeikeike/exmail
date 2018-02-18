defmodule Exmail.SMTPServ.Parser do
  alias Exmail.SMTPServ.Func

  require Logger

  def parse_mail_data({"multipart" = _content_type, _content_subtype, mail_meta, _, body}) do
    parse_mail_bodies(body)
    |> Map.merge(extract_mail_meta(mail_meta))
  end

  def parse_mail_data({"text" = _content_type, content_subtype, mail_meta, _, body})
    when content_subtype == "plain" or content_subtype == "html" do

    case content_subtype do
      "html"  -> %{"html_body"  => body}
      "plain" -> %{"plain_body" => body}
    end
    |> Map.merge(extract_mail_meta(mail_meta))
  end

  def parse_mail_data(body) when is_binary(body) do
    %{"unknown_body" => body}
  end

  def parse_mail_data({_content_type, _content_subtype, mail_meta, _, body}) do
    parse_mail_data(body)
    |> Map.merge(extract_mail_meta(mail_meta))
  end


  defp parse_mail_bodies(body) when is_binary(body) do
    %{"unparsed_body" => body}
  end

  defp parse_mail_bodies(bodies) do
    parse_mail_bodies bodies, %{}
  end

  defp parse_mail_bodies([], collected) do
    collected
  end

  defp parse_mail_bodies([body | bodies], collected) do
    new_collected = Map.merge(collected, parse_mail_data(body))
    parse_mail_bodies(bodies, new_collected)
  end


  defp extract_mail_meta(mail_meta) do
    Enum.reduce mail_meta, %{}, fn({field, value}, data) ->
      formatted_value = format_field_value(field, value)
      Map.put(data, field, formatted_value)
    end
  end


  defp format_field_value("To", value) do
    Func.parse_participants(value)
  end

  defp format_field_value("From", value) do
    Func.parse_participant(value)
  end

  defp format_field_value(_field, value) do
    value
  end

  def parse_bounce_data(data) do
    Exmail.File.store_temporary data, f: fn fpath ->
      with {:ok, [bounce|_]} <- parse_bounce fpath do
        bounce
      else error ->
        Logger.warn("[parse_bounce_data] #{inspect error}")
      end
    end
  end

  # require "sisimai"
  # #-> true
  #
  defp parse_bounce(fpath) do
    opts = ["-rubygems", "-e", ~s|'require "sisimai"; puts Sisimai.dump($*.shift)'|, fpath]
    Poison.decode :os.cmd('ruby #{Enum.join opts, " "}')
  end

end
