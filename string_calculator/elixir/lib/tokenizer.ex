defmodule SC.Tokenizer do
  def get_numbers(graphemes, separator) do
    tokenize(graphemes, separator)
  end

  # Tokenizer *********************************************************
  def tokenize(
        input,
        separator \\ ",",
        tokens \\ [],
        current_token \\ %Token{value: "", position: 0, type: :num},
        position \\ 0
      )

  def tokenize(input, separator, _tokens, _current_token, _position)
      when is_bitstring(input) do
    input
    |> String.graphemes()
    |> tokenize(separator)
  end

  def tokenize(input, _separator, tokens, %Token{} = current_token, _) when input == [] do
    tokens = tokens ++ [current_token]

    {numbers, errors} = to_numbers_list(tokens)

    if errors == [] do
      {:ok, numbers}
    else
      {:error, errors |> Enum.join("\n")}
    end
  end

  def tokenize(input, separator, tokens, %Token{} = current_token, position)
      when is_list(input) do
    [hd | tl] = input

    case hd do
      ^separator when current_token.value != "" ->
        tokenize(
          tl,
          separator,
          tokens ++ [current_token, %Token{value: ",", position: position, type: :sep}],
          Token.new(position + 1),
          position + 1
        )

      "\n" when current_token.value != "" ->
        tokenize(
          tl,
          separator,
          tokens ++ [current_token, %Token{value: "\n", position: position, type: :sep}],
          Token.new(position + 1),
          position + 1
        )

      "," ->
        tokenize(
          tl,
          separator,
          tokens ++ [%Token{value: ",", position: position, type: :sep}],
          Token.new(position + 1),
          position + 1
        )

      "\n" ->
        tokenize(
          tl,
          separator,
          tokens ++ [%Token{value: "\n", position: position, type: :sep}],
          Token.new(position + 1),
          position + 1
        )

      " " ->
        tokenize(tl, separator, tokens, current_token, position + 1)

      hd ->
        new_value = current_token.value <> hd

        tokenize(
          tl,
          separator,
          tokens,
          %Token{current_token | value: new_value},
          position + 1
        )
    end
  end

  # To numbers list *********************************************************

  defp to_numbers_list(tokens, errors \\ [], numbers \\ [])

  defp to_numbers_list(tokens, errors, numbers) when tokens == [],
    do: {numbers, errors}

  defp to_numbers_list([last_element], errors, numbers) do
    {numbers, errors} =
      if Enum.member?([",", "\n"], last_element) do
        {numbers, add_error(errors, "EOF", last_element.position)}
      else
        case to_number(last_element.value) do
          {:error, _} ->
            {numbers, add_error(errors, last_element.value, last_element.position)}

          num ->
            {numbers ++ [num], errors}
        end
      end

    to_numbers_list([], errors, numbers)
  end

  defp to_numbers_list(tokens, errors, numbers) when length(tokens) >= 2 do
    [hd | tl] = tokens
    [sep | tl] = tl

    {numbers, errors} =
      case {hd.type, sep.type} do
        {:num, :sep} ->
          case to_number(hd.value) do
            {:error, _} ->
              {numbers, add_error(errors, hd.value, hd.position)}

            num ->
              {numbers ++ [num], errors}
          end

        {:sep, _} ->
          {numbers, add_error(errors, hd.value, hd.position)}
      end

    to_numbers_list(tl, errors, numbers)
  end

  defp add_error(errors, value, position) do
    errors ++
      [
        "Number expected but '#{value}' was found at position #{position}."
      ]
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
end
