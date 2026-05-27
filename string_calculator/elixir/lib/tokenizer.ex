defmodule SC.Tokenizer do
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

    errors =
      tokens
      |> Enum.filter(&(&1.type == :error))
      |> Enum.map(&"Number expected but '#{&1.value}' was found at position #{&1.position}.")

    errors = errors ++ check_tokens(tokens)

    if Enum.count(errors) > 0 do
      {:errors, errors |> Enum.join("\n")}
    else
      {:ok, tokens}
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
        cond do
          # 48 => '0' and 57 => '9'
          hd >= <<48>> && hd <= <<57>> ->
            new_value = current_token.value <> hd

            tokenize(
              tl,
              separator,
              tokens,
              %Token{current_token | value: new_value},
              position + 1
            )

          # 46 => '.'
          hd == <<46>> ->
            new_value = current_token.value <> hd

            tokenize(
              tl,
              separator,
              tokens,
              %Token{current_token | value: new_value},
              position + 1
            )

          true ->
            tokens = tokens ++ [%Token{value: hd, position: position, type: :error}]

            tokenize(
              tl,
              separator,
              tokens,
              Token.new(position + 1),
              position + 1
            )
        end
    end
  end

  defp check_tokens(tokens, errors \\ [])

  defp check_tokens(tokens, errors) when tokens == [] and errors == [], do: errors

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
end
