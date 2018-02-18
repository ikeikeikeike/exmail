defmodule Exmail.Markup do
  defmodule TextExtractor do
    @moduledoc false

    def get(html_tree, sep \\ "") do
      get_text(html_tree, "", sep)
    end

    defp get_text(text, "", _sep) when is_binary(text), do: text
    defp get_text(text, acc, sep) when is_binary(text), do: Enum.join([acc, text], sep)
    defp get_text(nodes, acc, sep) when is_list(nodes) do
      Enum.reduce nodes, acc, fn(child, istr) ->
        get_text(child, istr, sep)
      end
    end
    defp get_text({:comment, _}, acc, _), do: acc
    defp get_text({"br", _, _}, acc, _), do: acc <> "\n"
    defp get_text({"a", [{"href", src}| _], _}, acc, _), do: " #{acc} #{src} "
    defp get_text({_, _, nodes}, acc, sep) do
      get_text(nodes, acc, sep)
    end
  end

  def generate_text(html) when is_binary(html) do
    Floki.find(html, "body")
    |> generate_text()
  end

  def generate_text(doc) do
    doc
    |> TextExtractor.get
    |> String.split(["\n", "\r", "\r\n"])
    |> Enum.map(&String.lstrip/1)
    |> Enum.join("\n")
  end

  defmodule Transformer do
    @moduledoc false

    def transform(html_tree_list, transformation) when is_list(html_tree_list) do
      Enum.map(html_tree_list, fn(html_tree) ->
        apply_transformation(html_tree, transformation)
      end)
    end
    def transform(html_tree, transformation) do
      apply_transformation(html_tree, transformation)
    end

    def apply_transformation({name, attrs, rest}, transformation) do
      {new_name, new_attrs, new_rest} = transformation.({name, attrs, rest})

      new_rest = Enum.map(new_rest, fn(html_tree) ->
        apply_transformation(html_tree, transformation)
      end)

      {new_name, new_attrs, new_rest}
    end
    def apply_transformation(other, _transformation), do: other
  end

end
