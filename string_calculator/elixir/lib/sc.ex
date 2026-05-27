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

    with {:ok, numbers} <- Tokenizer.tokenize(graphemes, separator) do
      numbers |> Enum.sum() |> from_num_to_string
    end
  end

  def get_separator(["/", "/", sep | rest]), do: {sep, rest}
  def get_separator(tokens), do: {",", tokens}

  defp from_num_to_string(number) do
    cond do
      is_float(number) -> {:ok, Float.to_string(number)}
      is_integer(number) -> {:ok, Integer.to_string(number)}
      true -> raise "Not Supposed to happen"
    end
  end
end
