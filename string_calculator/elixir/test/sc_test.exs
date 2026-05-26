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
    result = SC.tokenize("3,2,12.15\n32,21")

    assert result ==
             {:ok,
              [
                %Token{value: "3", position: 0, type: :num},
                %Token{value: ",", position: 1, type: :sep},
                %Token{value: "2", position: 2, type: :num},
                %Token{value: ",", position: 3, type: :sep},
                %Token{value: "12.15", position: 4, type: :num},
                %Token{value: "\n", position: 9, type: :sep},
                %Token{value: "32", position: 10, type: :num},
                %Token{value: ",", position: 12, type: :sep},
                %Token{value: "21", position: 13, type: :num}
              ]}
  end

  test "user can choose the number separator with // operator" do
    result = SC.add("//;\n1;2")
  end
end
