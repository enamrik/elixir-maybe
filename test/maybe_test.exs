defmodule ElixirMaybe.MaybeTest do
  use ExUnit.Case
  alias ElixirMaybe.Maybe

  describe "Maybe" do
    test "Can map nothing" do
      value = Maybe.nothing
      assert Maybe.map(value, fn x -> x + 1 end) == :nothing
    end

    test "Can map something" do
      value = Maybe.just(2)
      assert Maybe.map(value, fn x -> x + 1 end) == {:just, 3}
    end

    test "Can chain on nothing" do
      value = Maybe.nothing
      result = value
               |> Maybe.then(fn x -> Maybe.just(x + 1) end)
               |> Maybe.then(fn x -> Maybe.just(x + 2) end)
      assert result  == :nothing
    end

    test "Can chain on something" do
      value = Maybe.just(2)
      result = value
               |> Maybe.then(fn x -> Maybe.just(x + 1) end)
               |> Maybe.then(fn x -> Maybe.just(x + 2) end)
      assert result  == {:just, 5}
    end

    test "Can terminate Maybe chain with nothing" do
      value = Maybe.just(2)
      result = value
               |> Maybe.then(fn x -> Maybe.just(x + 1) end)
               |> Maybe.then(fn _ -> Maybe.nothing end)
               |> Maybe.from_maybe(
                    value:   fn _ -> "Something" end,
                    nothing: fn -> "Nothing" end
                  )
      assert result  == "Nothing"
    end

    test "Can terminate Maybe chain with something" do
      value = Maybe.just(2)
      result = value
               |> Maybe.then(fn x -> Maybe.just(x + 1) end)
               |> Maybe.then(fn x -> Maybe.just(x + 2) end)
               |> Maybe.from_maybe(
                    value:   fn _ -> "Something" end,
                    nothing: fn -> "Nothing" end
                  )
      assert result  == "Something"
    end

    test "Can return value or default" do
      maybe = Maybe.just(2)
      assert Maybe.value_or_default(maybe, 1) == 2

      maybe = Maybe.nothing()
      assert Maybe.value_or_default(maybe, 1) == 1
    end

    test "Can catch nothing" do
      value = Maybe.just(2)
      result = value
               |> Maybe.then(fn x -> Maybe.just(x + 1) end)
               |> Maybe.then(fn _ -> Maybe.nothing end)
               |> Maybe.catch_nothing(fn-> Maybe.just(5) end)
               |> Maybe.from_maybe(
                    value:   fn v -> v end,
                    nothing: fn -> 0 end
                  )
      assert result  == 5
    end

    test "Can merge maybes" do
      value = [Maybe.just(2), Maybe.just(4), Maybe.nothing()]
              |> Maybe.maybe_all
              |> Maybe.map(fn list -> Enum.reduce(list, 0, &(&1 + &2)) end)
              |> Maybe.value_or_default(0)

      assert value == 6
    end

    test "let `then` be turned into `map` if `then` function doesn't return Maybe" do
      value = Maybe.just(1)
      result = value
               |> Maybe.then(fn x -> Maybe.just(x + 1) end)
               |> Maybe.then(fn x -> x + 5 end)
               |> Maybe.value_or_default(0)

      assert result  == 7
    end

    test "can resume processing on catching nothing" do
      value = Maybe.just(1)
      result = value
               |> Maybe.then(fn _ -> Maybe.nothing() end)
               |> Maybe.catch_nothing(fn-> 5 end)
               |> Maybe.value_or_default(0)

      assert result  == 5
    end
  end
end
