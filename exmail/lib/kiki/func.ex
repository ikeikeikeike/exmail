defmodule Exmail.Func do

  def themodule(%{__struct__: module}), do: module
  def themodule(module), do: module

  def thename(mod) do
    mod
    |> themodule()
    |> to_string
    |> String.split(".")
    |> List.last
    |> String.downcase
  end

  def fint!(numeric) when is_integer(numeric) do
    numeric
  end
  def fint!(numeric) when is_float(numeric) do
    round numeric
  end
  def fint!(numeric) when is_binary(numeric) do
    {n, _} = Integer.parse numeric
     n
  end
  def fint!(%Decimal{} = numeric) do
    Decimal.to_integer numeric
  end
  def fint!(value), do: raise ArgumentError, message: "value: #{inspect value}"
end
