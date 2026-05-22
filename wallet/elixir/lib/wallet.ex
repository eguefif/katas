defmodule Stock do
  @enforce_keys [:quantity, :type]
  defstruct [:quantity, :type]
end

defmodule Wallet do
  @enforce_keys [:stock, :currency, :rate_provider]
  defstruct [:stock, :currency, :rate_provider]

  def compute_value(
        %Wallet{stock: %Stock{quantity: quantity} = _stock, rate_provider: rate} = _wallet
      ) do
    quantity * rate
  end
end
