defmodule SC do
  def add(numbers) do
    numbers
    |> numbers_int
    |> Enum.reduce(0, fn x, acc -> acc + x end)
    |> from_num_to_string
  end

  defp numbers_int(numbers) do
    numbers
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&to_number/1)
  end

  defp to_number(number_str) do
    cond do
      String.match?(number_str, ~r/[0-9]+(.[0-9]*){1}/) ->
        String.to_float(number_str)

      String.match?(number_str, ~r/[0-9]+/) ->
        String.to_integer(number_str)

      true ->
        0
    end
  end

  defp from_num_to_string(number) do
    if is_float(number) do
      Float.to_string(number)
    else
      Integer.to_string(number)
    end
  end
end
