defmodule ItemWrapper do
  # @enforce_keys [:pattern, :direction, :mul, :thresholds, :perishable]
  defstruct [:pattern, :direction, :mul, :thresholds, :perishable, :item]

  # To add a new item type, append a map to @items (matched top-to-bottom, first wins):
  #
  #   pattern:    regex matched against the lowercased item name
  #   direction:  :inc (quality rises), :dec (quality falls), :none (quality unchanged)
  #   mul:        multiplier applied to the delta (e.g. 2 for Conjured double-degrades)
  #   thresholds: list of {sell_in_cutoff, new_delta} pairs, evaluated in order;
  #               when sell_in is below a cutoff the delta becomes new_delta
  #               e.g. [{10, 2}, {5, 3}] means +2 under 10 days, +3 under 5 days
  #   perishable: true drops quality to 0 when sell_in goes negative (e.g. Backstage passes)
  @items [
    %{
      pattern: ~r/aged brie/,
      direction: :inc,
      mul: 1,
      thresholds: [{0, 2}],
      perishable: false
    },
    %{
      pattern: ~r/backstage passes/,
      direction: :inc,
      mul: 1,
      thresholds: [{10, 2}, {5, 3}],
      perishable: true
    },
    %{
      pattern: ~r/conjured/,
      direction: :dec,
      mul: 2,
      thresholds: [{0, 2}],
      perishable: false
    },
    %{
      pattern: ~r/sulfuras/,
      direction: :none,
      mul: 1,
      thresholds: [],
      perishable: false
    },
    %{
      pattern: ~r/.*/,
      direction: :dec,
      mul: 1,
      thresholds: [{0, 2}],
      perishable: false
    }
  ]

  # This function will apply a series of modification based on
  # the information in the struct
  def update(%Item{} = item) do
    item
    |> wrap_item()
    |> decrease_sell_in()
    |> update_quality()
    |> apply_perishable()
  end

  def wrap_item(item) do
    wrapper =
      @items
      |> Enum.find(fn %{pattern: pattern} = _item_wrapper ->
        String.match?(String.downcase(item.name), pattern)
      end)

    wrapper = Map.put(wrapper, :item, item)

    struct!(%ItemWrapper{}, wrapper)
  end

  defp decrease_sell_in(%ItemWrapper{direction: direction} = wrapper) when direction == :none,
    do: wrapper

  defp decrease_sell_in(%ItemWrapper{item: %Item{} = item} = wrapper) do
    %ItemWrapper{wrapper | item: %Item{item | sell_in: item.sell_in - 1}}
  end

  defp update_quality(
         %ItemWrapper{
           direction: direction,
           mul: mul,
           thresholds: thresholds,
           item: %Item{quality: quality} = item
         } =
           wrapper
       )
       when direction == :dec and quality > 0 do
    delta = get_delta(item.sell_in, thresholds)

    item =
      if quality - delta * mul < 0 do
        %Item{item | quality: 0}
      else
        %Item{item | quality: quality - delta * mul}
      end

    %ItemWrapper{wrapper | item: item}
  end

  defp update_quality(
         %ItemWrapper{
           direction: direction,
           mul: mul,
           thresholds: thresholds,
           item: %Item{quality: quality} = item
         } =
           wrapped_item
       )
       when direction == :inc and quality < 50 do
    delta = get_delta(item.sell_in, thresholds)

    item =
      if delta * mul + quality > 50 do
        %Item{item | quality: 50}
      else
        %Item{item | quality: quality + delta * mul}
      end

    %ItemWrapper{wrapped_item | item: item}
  end

  defp update_quality(%ItemWrapper{} = wrapper),
    do: wrapper

  defp get_delta(sell_in, thresholds, retval \\ 1)

  defp get_delta(_sell_in, thresholds, retval) when thresholds == [], do: retval

  defp get_delta(sell_in, thresholds, retval) do
    [hd | tl] = thresholds

    case sell_in < elem(hd, 0) do
      true -> get_delta(sell_in, tl, elem(hd, 1))
      false -> retval
    end
  end

  defp apply_perishable(
         %ItemWrapper{item: %Item{} = item, perishable: perishable} = _wrapped_item
       )
       when item.sell_in < 0 and perishable == true do
    %Item{item | quality: 0}
  end

  defp apply_perishable(%ItemWrapper{item: %Item{} = item} = _wrapped_item), do: item
end
