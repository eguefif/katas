require 'rspec'

require File.join(File.dirname(__FILE__), 'gilded_rose')

describe GildedRose do
  it 'does not change the name' do
    items = [Item.new('foo', 0, 0)]
    GildedRose.new(items).update_quality
    expect(items[0].name).to eq 'foo'
  end

  describe '#special_item?' do
    it 'return  true if Aged Brie item is special' do
      item = Item.new('Aged Brie', 0, 0)
      result = GildedRose.new([item]).special_item?(item)
      expect(result).to be true
    end

    it 'return true if Backstage passes ticket item is special' do
      item = Item.new('Backstage passes ticket', 0, 0)
      result = GildedRose.new([item]).special_item?(item)
      expect(result).to be true
    end
  end

  describe '#legendary_item?' do
    it 'returns true if item\'s name is sulfuras, Hand of Ragnaros' do
      item = Item.new('Sulfuras, Hand of Ragnaros', 0, 0)
      result = GildedRose.new([item]).legendary_item?(item)
      expect(result).to be true
    end
  end
end
