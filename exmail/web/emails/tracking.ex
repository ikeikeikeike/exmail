defmodule Exmail.Emails.Tracking do

  import Exmail.Markup.Transformer, only: [transform: 2]

  @doc """
  Embed tracking URL for open rate
  """
  def embed_open(html, trackuri) do
    transformer = fn
      {"body", attrs, docs} ->
        o = [{"img", [src: trackuri, height: 1, width: 1], []}]
        {"body", attrs, docs ++ o}

      otherwise ->
        otherwise
    end

    html
    |> Floki.parse
    |> transform(transformer)
    |> Floki.raw_html
  end

  @doc """
  Embed track clicks in the html version of your email by replacing all links with tracking URLs.
  """
  def embed_html_click(html, trackuri) do
    transform = Floki.attr html, "a", "href", fn
    "http:"  <> _ = href ->
      String.replace(href, href, trackuri <> "?l=" <> href)
    "https:" <> _ = href ->
      String.replace(href, href, trackuri <> "?l=" <> href)
    invalid ->
      invalid
    end

    Floki.raw_html transform
  end

  @doc """
  Embed track clicks in the plain-text version of your email by replacing all links with tracking URLs.

  ### Sample

    text = '''
    https://google.com

    http://google.com

    http://example.com
    '''

    IO.puts embed_text_click(text, "https://proxy.com")
    '''
    https://proxy.com/?l=https://google.com

    https://proxy.com/?l=http://google.com

    https://proxy.com/?l=http://example.com
    '''

  """
  def embed_text_click(text, "http" <> _ = trackuri) do
    base  = String.replace trackuri, ["http://", "https://"], "replace://"

    [h|t] = String.split text, "https://"
    text  = [h] ++ Enum.map t, fn line ->
      base <> "?l=" <> "tracks://" <> line
    end

    [h|t] = String.split Enum.join(text), "http://"
    text  = [h] ++ Enum.map t, fn line ->
      base <> "?l=" <> "track://" <> line
    end

    Enum.join(text)
    |> String.split("track://") |> Enum.join("http://")
    |> String.split("tracks://") |> Enum.join("https://")
    |> String.split("replace://") |> Enum.join(URI.parse(trackuri).scheme <> "://")
  end

end
