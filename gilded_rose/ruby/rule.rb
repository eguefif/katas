class Rule
  # Recipe: How to add a new item
  # A new item need the following information
  #   * pattern: regex that will tell the code to use this set of rules or not
  #   * direction: two possible values :inc/:dec depending on if the item increase in quality over time or the opposite way around
  #   * threshold: this will be used to determine how much should we inc/dec the quality depending on how big is sell_in. This is an array of array[threshold, new delta]. The default delta is 1. If sell_in goes under threshold, we use the new delta value
  #   * perishable: if true, when sell_in < 0, quality drop to 0
  ITEM_RULES = [
    { pattern: /aged brie/, direction: :inc, mul: 1, threshold: [[0, 2]], perishable: false },
    { pattern: /backstage passes/, direction: :inc, mul: 1, threshold: [[10, 2], [5, 3]], perishable: true },
    { pattern: /conjured /, direction: :dec, mul: 2, threshold: [[0, 2]], perishable: false },
    { pattern: /sulfuras/, direction: :none, mul: 0, threshold: [], perishable: false }
  ].freeze

  attr_accessor :direction, :mul, :perishable

  # TODO: refactor threshold,
  def initialize(name)
    rules = rules_from_item_name(name)
    @direction = rules[:direction]
    @mul = rules[:mul]
    @threshold = rules[:threshold]
    @perishable = rules[:perishable]
  end

  private def rules_from_item_name(name)
    rules = ITEM_RULES.find { |rule| name.downcase.start_with?(rule[:pattern]) }

    if rules.nil?
      { direction: :dec, mul: 1, threshold: [[0, 2]], perishable: false }
    else
      rules
    end
  end

  def delta(sell_in)
    delta = 1
    @threshold.each do |value|
      delta = value[1] if sell_in < value[0]
    end
    delta
  end
end
