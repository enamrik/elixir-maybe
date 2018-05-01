defmodule ElixirMaybe.EnumExt do
  alias ElixirMaybe.Maybe

  def first(list) do
    case Enum.take(list, 1) do
      []        -> Maybe.nothing()
      [value|_] -> Maybe.just(value)
    end
  end
end