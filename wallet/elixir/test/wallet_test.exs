defmodule WalletTest do
  use ExUnit.Case
  doctest Wallet

  test "compute value for PETROLEUM and quantity 5 in EUR" do
    value =
      Wallet.compute_value(%Wallet{
        stock: %Stock{quantity: 5, type: :petroleum},
        currency: :eur,
        rate_provider: &RateProvider.rate/2
      })

    assert value == 500
  end
end
