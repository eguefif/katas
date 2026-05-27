defmodule SC do
  alias SC.Tokenizer

  def add(input) when is_binary(input) do
    do_add(input)
  end

  def add(input) when is_list(input) do
    input
    |> Enum.join(",")
    |> do_add()
  end

  defp do_add(input) do
    {separator, graphemes} =
      String.graphemes(input)
      |> get_separator()

    with {:ok, numbers} <- Tokenizer.get_numbers(graphemes, separator),
         :ok <- check_negative_number(numbers) do
      numbers |> Enum.sum() |> from_num_to_string |> then(&{:ok, &1})
    end
  end

  def get_separator(["/", "/", sep | rest]), do: {sep, rest}
  def get_separator(tokens), do: {",", tokens}

  def check_negative_number(numbers, negatives \\ [])

  def check_negative_number(numbers, negatives) when numbers == [] and negatives == [], do: :ok

  def check_negative_number(numbers, negatives) when numbers == [],
    do:
      {:error,
       "Negative not allowed : #{negatives |> Enum.map(&from_num_to_string/1) |> Enum.join(", ")}"}

  def check_negative_number(numbers, negatives) do
    [hd | tl] = numbers

    if hd >= 0,
      do: check_negative_number(tl, negatives),
      else: check_negative_number(tl, negatives ++ [hd])
  end

  defp from_num_to_string(number) do
    cond do
      is_float(number) -> Float.to_string(number)
      is_integer(number) -> Integer.to_string(number)
      true -> raise "Not Supposed to happen"
    end
  end
end
