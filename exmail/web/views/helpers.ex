defmodule Exmail.Helpers do
  alias Plug.Conn

  alias Exmail.{Hash}

  def locale do
    Gettext.get_locale(Exmail.Gettext)
  end

  def translate_default({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(Exmail.Gettext, "default", msg, msg, count || 0, opts)
    else
      Gettext.dgettext(Exmail.Gettext, "default", msg, opts)
    end
  end
  def translate_default(msg) do
    Gettext.dgettext(Exmail.Gettext, "default", "#{msg}")
  end

  defdelegate randstring(len), to: Hash, as: :randstring

  def fallback_image do
    "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAAB" <>
    "CAYAAAAfFcSJAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAA" <>
    "AJcEhZcwAADsQAAA7EAZUrDhsAAAANSURBVBhXYzh8+PB/AAffA0nNPuCLAAAAAElFTkSuQmCC"
  end

  def render_with(module, template, assigns) do
    {_, _, fnames} = module.__templates__
    if template in fnames do
      module.render template, assigns
    else
      render_with template, assigns
    end
  end

  def render_with(template, assigns) do
    {layout, _} = assigns.conn.private.phoenix_layout
    layout.render template, assigns
  end

  def redirect_back(conn, alternative \\ "/") do
    conn
    |> Conn.get_req_header("referer")
    |> referrer()
    |> Kernel.||(alternative)
  end

  defp referrer([]),    do: nil
  defp referrer([h|_]), do: h

  def name_tempalte(title) do
    (title || "")
    |> String.split(["-", "_"])
    |> Enum.join(" ")
    |> String.capitalize
  end

  def take_params(%Plug.Conn{} = conn, keys)
    when is_list(keys),
    do: take_params(conn, keys, %{})

  def take_params(%Plug.Conn{} = conn, keys, merge)
    when is_list(keys) and is_list(merge),
    do: take_params(conn, keys, Enum.into(merge, %{}))

  def take_params(%Plug.Conn{} = conn, keys, merge) do
    conn.params
    |> Map.take(keys)
    |> Map.merge(merge)
  end

  def take_hidden_field_tags(%Plug.Conn{} = conn, keys) when is_list(keys) do
    Enum.map take_params(conn, keys), fn{key, value} ->
      Phoenix.HTML.Tag.tag(:input, type: "hidden", id: key, name: key, value: value)
    end
  end

  def carried_params do
    ~w(q search maker label series category tag)
  end

  def to_keylist(params) do
    Enum.reduce params, [], fn {k, v}, kw ->
      Keyword.put kw, :"#{k}", v
    end
  end

  def to_qstring(params) do
    "?" <> URI.encode_query params
  end

  def view_time(datetime) do
    Timex.format!(Timex.Timezone.convert(datetime, "Asia/Tokyo"), "%b/%e/%y %l:%M%p", :strftime)
  end

  def view_time(datetime, :detail) do
    Timex.format!(Timex.Timezone.convert(datetime, "Asia/Tokyo"), "%B %d %Y %l:%M %P", :strftime)
  end

  def gravatar(email, size \\ 100) do
    md5 = Hash.md5 email
    "https://www.gravatar.com/avatar/" <> md5 <> "?s=#{size}"
  end

  def googlemap(latlon) do
    "https://www.google.com/maps?q=" <> latlon
  end

  def uniquify(elems)
      when is_list(elems) do
    Enum.uniq elems
  end
  def uniquify(elems) do
    [elems]
  end
  def uniquify(elems, keys)
      when is_list(elems)
       and is_list(keys) do
    Enum.uniq_by elems, &Map.take(&1, keys)
  end
  def uniquify(elems, key)
      when is_list(elems) do
    Enum.uniq_by elems, &Map.take(&1, [key])
  end
  def uniquify(elems, _) do
    [elems]
  end

  def renderable(uri) do
    case HTTPoison.get(uri) do
      {:ok, %{body: body, status_code: status}} when status < 400 ->
        {:safe, body}
      _ ->
        {:safe, "There is no Reader"}
    end
  end

  def codeable(uri) do
    case HTTPoison.get uri do
      {:ok, %{body: body, status_code: status}} when status < 400 ->
        body
      _ ->
        "There is no Document"
    end
  end

end
