defmodule Stock do
  @enforce_keys [:quantity, :type]
  defstruct [:quantity, :type]

  @stock_types [:petroleum, :lng]

  def valid_stock_type?(stock_type) do
    Enum.any?(@stock_types, fn type -> stock_type == type end)
  end
end

defmodule RateProvider do
  def rate(currency, stock) when is_atom(stock) and is_atom(currency) do
    if Stock.valid_stock_type?(stock) do
      case get_data(currency, stock) do
        :error -> :unhandled_currency
        retval -> retval
      end
    else
      :unhandled_stock
    end
  end

  defp get_data(currency, stock) do
    data =
      case stock do
        :petroleum ->
          %{
            base: "petroleum",
            date: "2018-02-13",
            rates: %{
              CAD: 185,
              DOLL: 125,
              EUR: 135,
              GBP: 141
            }
          }

        :lng ->
          %{
            base: "lng",
            date: "2018-02-13",
            rates: %{
              CAD: 235.12,
              DOLL: 185,
              EUR: 195,
              GBP: 205
            }
          }
      end

    Map.fetch!(data, :rates)
    |> Map.to_list()
    |> Enum.map(fn {k, v} ->
      {k |> Atom.to_string() |> String.downcase() |> String.to_atom(), v}
    end)
    |> Keyword.fetch(currency)
  end
end

defmodule Wallet do
  @enforce_keys [:stock, :currency, :rate_provider]
  defstruct [:stock, :currency, :rate_provider]

  def compute_value(
        %Wallet{
          stock: %Stock{quantity: quantity, type: stock_type} = _stock,
          rate_provider: rate_provider,
          currency: currency
        } = _wallet
      ) do
    case rate_provider.(currency, stock_type) do
      {:ok, rate} -> {:ok, quantity * rate}
      error -> error
    end
  end
end
