defmodule SC do
  # TODO:: handle errors in to_number using a with
  def add(numbers) when is_binary(numbers) do
    numbers
    |> to_numbers_list
    |> add_numbers
  end

  def add(numbers) when is_list(numbers) do
    numbers
    |> Enum.flat_map(&to_numbers_list/1)
    |> add_numbers
  end

  defp to_numbers_list(numbers) do
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

      number_str == "" ->
        0

      true ->
        :error
    end
  end

  defp add_numbers(numbers_list) when is_list(numbers_list) do
    with {:ok, numbers_list} <- check_list(numbers_list) do
      numbers_list
      |> Enum.reduce(0, fn x, acc -> acc + x end)
      |> from_num_to_string
    else
      {:error, msg} -> {:error, msg}
    end
  end

  def check_list(numbers) when is_list(numbers) do
    numbers
    |> Enum.find_index(fn x -> x == :error end)
    |> then(fn x ->
      if x == nil, do: {:ok, numbers}, else: {:error, "Elements #{x} is not a number."}
    end)
  end

  defp from_num_to_string(number) do
    cond do
      is_float(number) -> {:ok, Float.to_string(number)}
      is_integer(number) -> {:ok, Integer.to_string(number)}
      true -> :error
    end
  end
end
