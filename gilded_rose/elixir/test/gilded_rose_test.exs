defmodule GildedRoseTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  test "Approval test 30 days" do
    expected =
      File.read!("test/ApprovalTest.ThirtyDays.verified.txt") |> String.replace("\r\n", "\n")

    result =
      capture_io(fn -> GildedRose.TextTestFixture.run(30) end) |> String.replace("\r\n", "\n")

    assert result == expected
  end

  test "decrease quality for regular item before sell_in" do
    items = [%Item{name: "foo", sell_in: 10, quality: 5}]
    items = GildedRose.update_quality(items)
    items = GildedRose.update_quality(items)
    items = GildedRose.update_quality(items)
    %{quality: qualityItem, sell_in: sell_in} = List.first(items)
    assert 7 == sell_in
    assert 2 == qualityItem
  end

  test "decrease quality for regular item after sell_in" do
    items = [%Item{name: "foo", sell_in: 10, quality: 15}]
    items = apply_update_quality_loop(items, 11)
    item = List.first(items)
    assert -1 == item.sell_in
    assert 3 == item.quality
  end

  def apply_update_quality_loop(items, count) when count == 0, do: items

  def apply_update_quality_loop(items, count) do
    items = apply_update_quality_loop(items, count - 1)
    GildedRose.update_quality(items)
  end

  test "increase quality for special Aged Brie item before sell_in" do
    items = [%Item{name: "Aged Brie", sell_in: 5, quality: 8}]
    items = apply_update_quality_loop(items, 3)
    item = List.first(items)
    assert 2 == item.sell_in
    assert 11 == item.quality
  end

  test "increase quality for special Aged Brie item after sell_in" do
    items = [%Item{name: "Aged Brie", sell_in: 5, quality: 8}]
    items = apply_update_quality_loop(items, 6)
    item = List.first(items)
    assert -1 == item.sell_in
    assert 15 == item.quality
  end

  test "stop incresing Aged Bried when quality greater than 50" do
    items = [%Item{name: "Aged Brie", sell_in: 5, quality: 8}]
    items = apply_update_quality_loop(items, 43)
    item = List.first(items)
    assert 50 == item.quality
  end

  test "increase quality for Backstage passes before sell_in, greater than 10" do
    items = [%Item{name: "Backstage passes for David Bowie", sell_in: 12, quality: 9}]
    items = apply_update_quality_loop(items, 2)
    item = List.first(items)
    assert 10 == item.sell_in
    assert 11 == item.quality
  end

  test "increase quality for backstage passes before sell_in, less than 10 and greater than 5" do
    items = [%Item{name: "Backstage passes for David Bowie", sell_in: 12, quality: 9}]
    items = apply_update_quality_loop(items, 3)
    item = List.first(items)
    assert 9 == item.sell_in
    assert 13 == item.quality
  end

  test "increase quality for backstage passes before sell_in, less than 5 and greater than 0" do
    items = [%Item{name: "Backstage passes for David Bowie", sell_in: 12, quality: 9}]
    items = apply_update_quality_loop(items, 8)
    item = List.first(items)
    assert 4 == item.sell_in
    assert 24 == item.quality
  end

  test "increase quality for backstage passes past sell_in" do
    items = [%Item{name: "Backstage passes for David Bowie", sell_in: 12, quality: 9}]
    items = apply_update_quality_loop(items, 13)
    item = List.first(items)
    assert -1 == item.sell_in
    assert 0 == item.quality
  end

  test "decrease quality for conjured before sell_in" do
    items = [%Item{name: "Conjured David Bowie", sell_in: 2, quality: 10}]
    items = apply_update_quality_loop(items, 2)
    item = List.first(items)
    assert 0 == item.sell_in
    assert 6 == item.quality
  end

  test "decrease quality for conjured after sell_in" do
    items = [%Item{name: "Conjured David Bowie", sell_in: 2, quality: 10}]
    items = apply_update_quality_loop(items, 3)
    item = List.first(items)
    assert -1 == item.sell_in
    assert 2 == item.quality
  end
end
