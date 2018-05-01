defmodule ElixirMaybe.EnumExtTest do
  alias ElixirMaybe.EnumExt
  use ExUnit.Case

  describe "EnumExt" do

    test "#first: can get first item in a list" do
      assert ["something", "else"] |> EnumExt.first == {:just, "something"}
    end

    test "#first: can get nothing in empty list" do
      assert [] |> EnumExt.first == :nothing
    end
  end
end
