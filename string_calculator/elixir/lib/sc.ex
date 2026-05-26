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
         :ok <- check_tokens(tokens) do
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

      _ ->
        :unexpected_error
    end
  end

  def tokenize(
        input,
        tokens \\ [],
        current_token \\ %Token{value: "", position: 0, type: :num},
        position \\ 0
      )

  def tokenize(input, _tokens, _current_token, _position)
      when is_bitstring(input) do
    input
    |> String.graphemes()
    |> tokenize()
  end

  def tokenize(input, tokens, %Token{} = current_token, _) when input == [] do
    tokens = tokens ++ [current_token]

    if Enum.any?(tokens, &(&1.type == :error)) do
      {:tokenizer_error, tokens}
    else
      {:ok, tokens}
    end
  end

  def tokenize(input, tokens, %Token{} = current_token, position) when is_list(input) do
    [hd | tl] = input

    case hd do
      "," when current_token.value != "" ->
        tokenize(
          tl,
          tokens ++ [current_token, %Token{value: ",", position: position, type: :sep}],
          Token.new(position + 1),
          position + 1
        )

      "\n" when current_token.value != "" ->
        tokenize(
          tl,
          tokens ++ [current_token, %Token{value: "\n", position: position, type: :sep}],
          Token.new(position + 1),
          position + 1
        )

      "," ->
        tokenize(
          tl,
          tokens ++ [%Token{value: ",", position: position, type: :sep}],
          Token.new(position + 1),
          position + 1
        )

      "\n" ->
        tokenize(
          tl,
          tokens ++ [%Token{value: "\n", position: position, type: :sep}],
          Token.new(position + 1),
          position + 1
        )

      " " ->
        tokenize(tl, tokens, current_token, position + 1)

      hd ->
        cond do
          # 48 => '0' and 57 => '9'
          hd >= <<48>> && hd <= <<57>> ->
            new_value = current_token.value <> hd
            tokenize(tl, tokens, %Token{current_token | value: new_value}, position + 1)

          # 46 => '.'
          hd == <<46>> ->
            new_value = current_token.value <> hd
            tokenize(tl, tokens, %Token{current_token | value: new_value}, position + 1)

          true ->
            tokens = tokens ++ [%Token{value: hd, position: position, type: :error}]

            tokenize(
              tl,
              tokens,
              Token.new(position + 1),
              position + 1
            )
        end
    end
  end

  defp check_tokens(tokens, errors \\ [])

  defp check_tokens(tokens, errors) when tokens == [] and errors == [], do: :ok

  defp check_tokens(tokens, errors) when tokens == [] do
    {:check_error, errors}
  end

  defp check_tokens([last_element], errors) do
    errors =
      if Enum.member?([",", "\n"], last_element) do
        errors ++ ["Number expected but EOF was found at position #{last_element.position}."]
      else
        errors
      end

    check_tokens([], errors)
  end

  defp check_tokens(tokens, errors) when length(tokens) >= 2 do
    [hd | tl] = tokens
    [sep | tl] = tl

    errors =
      case {hd.type, sep.type} do
        {:num, :sep} ->
          errors

        {:sep, _} ->
          errors ++
            [
              "Number expected but '#{hd.value}' was found at position #{hd.position}."
            ]
      end

    check_tokens(tl, errors)
  end

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
