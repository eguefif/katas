defmodule Stock do
  @enforce_keys [:quantity, :type]
  defstruct [:quantity, :type]

  @stock_types [:petroleum, :lng]

  def valid_stock_type?(stock_type) do
    Enum.any?(@stock_types, fn type -> stock_type == type end)
  end
end

defmodule RateProvider do
  @currencies [:eur, :doll]

  @eur %{petroleum: 100, lng: 95}
  @doll %{petroleum: 105, lng: 90}

  def rate(currency, stock) when is_atom(stock) and is_atom(currency) do
    case currency do
      :eur -> Map.fetch(@eur, stock)
      :doll -> Map.fetch(@doll, stock)
    end
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
      {:ok, rate} -> quantity * rate
      _ -> nil
    end
  end
end
