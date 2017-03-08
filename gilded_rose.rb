Delta = Struct.new(:delta)
FixedValue = Struct.new(:value)

class NormalExpiryStrategy
  def advance(days)
    days - 1
  end
end

class EternalExpiryStrategy
  def advance(days)
    days
  end
end

class QualityStrategy
  def initialize(min, max, ranges_to_changes)
    @min = min
    @max = max
    @ranges_to_changes = ranges_to_changes
  end

  def advance(item)
    _, change = ranges_to_changes.find { |range, _| range.include? item.sell_in }
    if change.is_a? Delta
      new_quality = item.quality + change.delta
    elsif change.is_a? FixedValue
      new_quality = change.value
    end
    new_quality.clamp(min, max)
  end

  private

  attr_reader :min, :max, :ranges_to_changes
end

module ItemProcessor
  def initialize(expiry_strategy, quality_strategy)
    @expiry_strategy = expiry_strategy
    @quality_strategy = quality_strategy
  end

  def match(item)
    return item.name == item_name
  end

  def update(item)
    update_expiry(item)
    update_quality(item)
    item
  end

  private

  attr_reader :expiry_strategy, :quality_strategy

  def update_expiry(item)
    item.sell_in = expiry_strategy.advance(item.sell_in)
  end

  def update_quality(item)
    item.quality = quality_strategy.advance(item)
  end
end


class AgedBrieItemProcessor
  include ItemProcessor
  ITEM_NAME_MATCHER = "Aged Brie"

  private

  def item_name
    ITEM_NAME_MATCHER
  end
end

class BackstagePassesItemProcessor
  include ItemProcessor
  ITEM_NAME_MATCHER = "Backstage passes to a TAFKAL80ETC concert"

  private

  def item_name
    ITEM_NAME_MATCHER
  end
end

class RegularOldItemProcessor
  include ItemProcessor

  def match(_)
    true
  end
end

class SulfurasItemProcessor
  include ItemProcessor
  ITEM_NAME_MATCHER = "Sulfuras, Hand of Ragnaros"

  private

  def item_name
    ITEM_NAME_MATCHER
  end
end

class GildedRose
  INF = Float::INFINITY
  NEGINF = -(Float::INFINITY)
  ITEM_PROCESSORS = [
    AgedBrieItemProcessor.new(NormalExpiryStrategy.new, QualityStrategy.new(0, 50, {
      (NEGINF..-1) => Delta.new(2),
      (0..INF) => Delta.new(1)
    })),
    BackstagePassesItemProcessor.new(NormalExpiryStrategy.new, QualityStrategy.new(0, 50, {
      (0..4) => Delta.new(2),
      (5..INF) => Delta.new(1),
      (NEGINF..-1) => FixedValue.new(0)
    })),
    SulfurasItemProcessor.new(EternalExpiryStrategy.new, QualityStrategy.new(80, 80, {
      (NEGINF..INF) => Delta.new(0),
    }))
  ]
  FALL_BACK_PROCESSOR = RegularOldItemProcessor.new(NormalExpiryStrategy.new, QualityStrategy.new(0, 50, {
    (0..INF) => Delta.new(-1),
    (NEGINF..-1) => Delta.new(-2)
  }))

  def initialize(items)
    @items = items
  end

  def update_quality()
    @items.each do |item|
      item_processor = ITEM_PROCESSORS.find { |processor| processor.match(item) }
      next item_processor.update(item) unless item_processor.nil?
      FALL_BACK_PROCESSOR.update(item)
    end
  end
end

class Item
  attr_accessor :name, :sell_in, :quality

  def initialize(name, sell_in, quality)
    @name = name
    @sell_in = sell_in
    @quality = quality
  end

  def to_s()
    "#{@name}, #{@sell_in}, #{@quality}"
  end
end
