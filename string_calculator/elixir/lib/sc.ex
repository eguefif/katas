defmodule SC do
  def add(input) when is_binary(input) do
    do_add(input)
  end

  def add(input) when is_list(input) do
    input
    |> Enum.join(",")
    |> do_add()
  end

  defp do_add(input) do
    graphemes = String.graphemes(input)

    with {:ok, tokens} <- tokenize(graphemes),
         {:ok, numbers} <- to_numbers_list(tokens) do
      numbers
      |> add_numbers
      |> from_num_to_string
    else
      {:error, tokens} ->
        Enum.filter(tokens, fn %Token{type: type} ->
          if type == :error, do: true, else: false
        end)
        |> Enum.map(fn %Token{value: value, position: idx} ->
          "Number expected but '#{value}' was found at position #{idx}."
        end)
        |> Enum.join("\n")
        |> then(&{:error, &1})
    end
  end

  def tokenize(
        input,
        tokens \\ [],
        current_token \\ %Token{value: "", position: 0, type: :num},
        position \\ 0
      )

  def tokenize(input, tokens, %Token{} = current_token, _) when input == [] do
    IO.inspect(current_token)
    IO.inspect(tokens)
    {:ok, [current_token | tokens]}
  end

  def tokenize(input, tokens, %Token{} = current_token, position) do
    [hd | tl] = input

    IO.inspect(current_token)
    IO.inspect(tokens)

    current_token =
      if current_token.value == "" do
        %Token{current_token | position: position}
      else
        current_token
      end

    case hd do
      "," ->
        tokenize(
          tl,
          [current_token | tokens],
          %Token{value: "", position: position, type: :none},
          position + 1
        )

      "\n" ->
        tokenize(
          tl,
          [current_token | tokens],
          %Token{value: "", position: position, type: :none},
          position + 1
        )

      " " ->
        tokenize(tl, tokens, current_token, position + 1)

      val when val >= <<48>> and val <= <<57>> ->
        new_value = current_token.value <> hd
        tokenize(tl, tokens, %Token{current_token | value: new_value}, position + 1)

      val when val == <<46>> ->
        new_value = current_token.value <> hd
        tokenize(tl, tokens, %Token{current_token | value: new_value}, position + 1)

      val ->
        tokens = [%Token{value: val, position: position, type: :error} | tokens]
        {:error, tokens}
    end
  end

  defp to_numbers_list(numbers) do
    IO.inspect(numbers)

    numbers
    |> Enum.filter(fn %Token{type: type} = _ -> type != :error end)
    |> Enum.map(& &1.value)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&to_number/1)
    |> then(fn numbers ->
      if Enum.any?(numbers, &is_tuple/1) do
        {:num_error, numbers}
      else
        {:ok, numbers}
      end
    end)
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

  defp add_numbers(numbers_list) when is_list(numbers_list) do
    with {:ok, numbers_list} <- check_list(numbers_list) do
      numbers_list
      |> Enum.reduce(0, fn x, acc -> acc + x end)
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
      true -> raise "Not Supposed to happen"
    end
  end
end
