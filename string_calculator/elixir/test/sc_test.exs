defmodule SCTest do
  use ExUnit.Case
  doctest SC

  test "Add an empty string" do
    result = SC.add("")
    assert result == "0"
  end

  test "Add a 5" do
    result = SC.add("5")
    assert result == "5"
  end

  test "Add integer 3, 5" do
    result = SC.add("3,5")
    assert result == "8"
  end

  test "Add float 3.2, 5" do
    result = SC.add("3.2,5")
    assert result == "8.2"
  end
end
