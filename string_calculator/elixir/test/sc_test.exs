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

  test "Add integer 32, 5,100" do
    {:ok, result} = SC.add("32, 5,100")
    assert result == "137"
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

  test "Returns an error if using 3,2, a" do
    result = SC.add("3,2,a")
    assert result == {:error, "Number expected but 'a' was found at position 4."}
  end

  test "Returns an error if using 3,2,\n5" do
    result = SC.add("3,2,\n52")
    assert result == {:error, "Number expected but '\n' was found at position 4."}
  end

  test "Returns an error if using 3,2\n,5" do
    result = SC.add("3,2\n,52")
    assert result == {:error, "Number expected but ',' was found at position 4."}
  end

  test "tokenizer" do
    result = SC.Tokenizer.tokenize("3,2,12.15\n32,21")

    assert result ==
             {:ok, [3, 2, 12.15, 32, 21]}
  end

  test "user can choose the number separator with // operator" do
    {:ok, result} = SC.add("//;1;2")
    assert result == "3"
  end
end
