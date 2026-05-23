defmodule SCTest do
  use ExUnit.Case
  doctest SC

  test "Add an empty string" do
    {:ok, result} = SC.add("")
    assert result == "0"
  end

  test "Add a 5" do
    {:ok, result} = SC.add("5")
    assert result == "5"
  end

  test "Add integer 3, 5" do
    {:ok, result} = SC.add("3,5")
    assert result == "8"
  end

  test "Add float 3.2, 5" do
    {:ok, result} = SC.add("3.2,5")
    assert result == "8.2"
  end

  test "Add from a list" do
    {:ok, result} = SC.add(["3.2,5", "1"])
    assert result == "9.2"
  end

  test "Add from a list with 3 elements" do
    {:ok, result} = SC.add(["3.2,5", "1", "1.1,2.1"])
    assert result >= "12.3"
    assert result <= "12.5"
  end
end
