require_relative 'rule'
class WrapperItem
  def initialize(item)
    @item = item
    @rules = Rule.new(item.name)
  end

  def update_quality
    return if @rules.direction == :none

    @item.sell_in -= 1

    apply_direction
    apply_perishable
    @item
  end

  def apply_perishable
    return unless @rules.perishable == true

    @item.quality = 0 if @item.sell_in < 0
  end

  def apply_direction
    case @rules.direction
    when :inc
      inc_quality
    when :dec
      dec_quality
    end
  end

  def inc_quality
    return unless @item.quality < 50

    if @item.quality + delta * @rules.mul > 50
      @item.quality = 50
    else
      @item.quality += delta * @rules.mul
    end
  end

  def dec_quality
    return unless @item.quality > 0

    @item.quality -= delta * @rules.mul
  end

  def delta
    @rules.delta(@item.sell_in)
  end
end
