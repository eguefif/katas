defmodule SC do
  alias SC.Tokenizer

  def multiply(input) when is_binary(input) do
    do_operation(input, :mul)
  end

  def multiply(input) when is_list(input) do
    input
    |> Enum.join(",")
    |> do_operation(:mul)
  end

  def add(input) when is_binary(input) do
    do_operation(input, :add)
  end

  def add(input) when is_list(input) do
    input
    |> Enum.join(",")
    |> do_operation(:add)
  end

  defp do_operation(input, operation) do
    {separator, graphemes} =
      String.graphemes(input)
      |> get_separator()

    operation = get_operation(operation)

    with {:ok, numbers} <- Tokenizer.get_numbers(graphemes, separator),
         :ok <- check_negative_number(numbers) do
      numbers |> operation.() |> from_num_to_string |> then(&{:ok, &1})
    end
  end

  def get_separator(["/", "/", sep | rest]), do: {sep, rest}
  def get_separator(tokens), do: {",", tokens}

  def get_operation(operation) do
    case operation do
      :add -> fn enum -> Enum.sum(enum) end
      :mul -> fn enum -> do_multiply(enum) end
    end
  end

  defp do_multiply([num]), do: num

  defp do_multiply(numbers) do
    [hd | tl] = numbers
    hd * do_multiply(tl)
  end

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
