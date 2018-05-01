defmodule ElixirMaybe.Maybe do

  def just(value) do
    {:just, value}
  end

  def nothing() do
    :nothing
  end

  def from_value(value) do
    case value do
      nil -> nothing()
      val -> just(val)
    end
  end

  def map(maybe, f) do
    case maybe do
      {:just, value} -> {:just, f.(value)}
      :nothing       -> :nothing
      _              -> raise_maybe_error("map", maybe)
    end
  end

  def then(maybe, f) do
    case maybe do
      :nothing       -> :nothing
      {:just, value} ->
        case f.(value) do
          {:just, next_value} -> {:just, next_value}
          :nothing            -> :nothing
          value               -> {:just, value}
        end

      _              -> raise_maybe_error("then", maybe)
    end
  end

  def maybe_all(maybes) do

    {value_results, _} = maybes |> eval_maybe_list

    if length(value_results) > 0,
       do:   just(value_results),
       else: nothing()
  end

  def catch_nothing(maybe, f) do
    case maybe do
      :nothing          ->
        case f.() do
          :nothing            -> :nothing
          {:just, next_value} -> {:just, next_value}
          value               -> {:just, value}
        end
      {:just, value}    -> {:just, value}
      _                 -> raise_maybe_error("catch_nothing", maybe)
    end
  end

  def value_or_default(maybe, default) do
    from_maybe(
      maybe,
      value: &(&1),
      nothing: fn-> default end
    )
  end

  def to_error(maybe, [if_nothing: error, else: just_f]) do
    from_maybe(
      maybe,
      value: just_f,
      nothing: fn-> error end
    )
  end

  def from_maybe(maybe, options) do
    [value: get_f, nothing: return_f] = options
    case maybe do
      {:just, value} -> get_f.(value)
      :nothing       -> return_f.()
      _              -> raise_maybe_error("from_maybe", maybe)
    end
  end

  defp eval_maybe_list(maybes) do
    value_results = maybes
                    |> Enum.map(&value_or_nil(&1))
                    |> Enum.filter(&(&1 != nil))

    nothing_results  = maybes
                       |> Enum.map(&value_or_nil(&1))
                       |> Enum.filter(&(&1 == nil))

    {value_results, nothing_results}
  end

  defp value_or_nil(maybe) do
    maybe |>
      from_maybe(
        value:   fn x -> x end,
        nothing: fn   -> nil end
      )
  end

  defp raise_maybe_error(method, value) do
    raise("Maybe.#{method}: Invalid Maybe: #{inspect(value)}. " <>
          "Supported formats: {:just, value}, :nothing. " <>
          "Use Maybe.just(value) or Maybe.nothing() to create an Maybe.")
  end
end