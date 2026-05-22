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

    assert value == {:ok, 500}
  end

  test "compute value for LNG and quantity 10 in DOLL" do
    value =
      Wallet.compute_value(%Wallet{
        stock: %Stock{quantity: 10, type: :lng},
        currency: :doll,
        rate_provider: &RateProvider.rate/2
      })

    assert value == {:ok, 900}
  end

  test "compute value for CORN and quantity 10 in DOLL" do
    value =
      Wallet.compute_value(%Wallet{
        stock: %Stock{quantity: 10, type: :corn},
        currency: :doll,
        rate_provider: &RateProvider.rate/2
      })

    assert value == :unhandled_stock
  end

  test "compute value for PETROLEUM and quantity 10 in roubles" do
    value =
      Wallet.compute_value(%Wallet{
        stock: %Stock{quantity: 10, type: :petroleum},
        currency: :roubles,
        rate_provider: &RateProvider.rate/2
      })

    assert value == :unhandled_currency
  end
end
