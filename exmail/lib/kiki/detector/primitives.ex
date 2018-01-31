defmodule Exmail.Detector.Primitives do

  def numeric?(num) when is_integer(num) do
    true
  end
  def numeric?(str) when is_binary(str) do
    case Float.parse(str) do
      {_num, ""} -> true
      {_num, _r} -> false  # _r : remainder_of_bianry
      :error     -> false
    end
  end
  def numeric?(_), do: false

end
