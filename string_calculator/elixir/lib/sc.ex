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

    with {:ok, tokens} <- Tokenizer.tokenize(graphemes, separator),
         :ok <- Tokenizer.check_tokens(tokens) do
      tokens |> add_numbers |> from_num_to_string
    else
      {:tokenizer_error, tokens} ->
        Enum.filter(tokens, fn %Token{type: type} ->
          if type == :error, do: true, else: false
        end)
        |> Enum.map(fn %Token{value: value, position: idx} ->
          "Number expected but '#{value}' was found at position #{idx}."
        end)
        |> Enum.join("\n")
        |> then(&{:error, &1})

      {:check_error, errors} ->
        Enum.join(errors, "\n")
        |> then(&{:error, &1})

      {:separator_error, error} ->
        {:error, error}

      _ ->
        :unexpected_error
    end
  end

  def get_separator(["/", "/", sep | rest]), do: {sep, rest}
  def get_separator(tokens), do: {",", tokens}

  defp add_numbers(numbers_list) do
    numbers_list
    |> Enum.filter(&(&1.type == :num))
    |> Enum.map(&to_number(&1.value))
    |> Enum.sum()
  end

  defp to_number(number_str) do
    cond do
      String.match?(number_str, ~r/[0-9]+[.]{1}[0-9]+/) ->
        String.to_float(number_str)

      String.match?(number_str, ~r/[0-9]+/) ->
        String.to_integer(number_str)

      number_str == "" ->
        0

      true ->
        {:error, number_str}
    end
  end

  defp from_num_to_string(number) do
    cond do
      is_float(number) -> {:ok, Float.to_string(number)}
      is_integer(number) -> {:ok, Integer.to_string(number)}
      true -> raise "Not Supposed to happen"
    end
  end
end
