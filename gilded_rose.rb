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

class SpecificItemProcessor
  include ItemProcessor

  def initialize(name, expiry_strategy, quality_strategy)
    @name = name
    super(expiry_strategy, quality_strategy)
  end

  def match(item)
    return item.name == name
  end

  private

  attr_reader :name
end

class FallbackItemProcessor
  include ItemProcessor

  def match(_)
    true
  end
end

class GildedRose
  MAX_DATE = Float::INFINITY
  MIN_DATE = -(Float::INFINITY)
  ITEM_PROCESSORS = [
    SpecificItemProcessor.new("Aged Brie", NormalExpiryStrategy.new, QualityStrategy.new(0, 50, {
      (MIN_DATE..-1) => Delta.new(2),
      (0..MAX_DATE) => Delta.new(1)
    })),
    SpecificItemProcessor.new("Backstage passes to a TAFKAL80ETC concert", NormalExpiryStrategy.new, QualityStrategy.new(0, 50, {
      (0..4) => Delta.new(2),
      (5..MAX_DATE) => Delta.new(1),
      (MIN_DATE..-1) => FixedValue.new(0)
    })),
    SpecificItemProcessor.new("Sulfuras, Hand of Ragnaros", EternalExpiryStrategy.new, QualityStrategy.new(80, 80, {
      (MIN_DATE..MAX_DATE) => Delta.new(0),
    }))
  ]
  FALLBACK_PROCESSOR = FallbackItemProcessor.new(NormalExpiryStrategy.new, QualityStrategy.new(0, 50, {
    (0..MAX_DATE) => Delta.new(-1),
    (MIN_DATE..-1) => Delta.new(-2)
  }))

  def initialize(items)
    @items = items
  end

  def update_quality()
    @items.each do |item|
      item_processor = ITEM_PROCESSORS.find { |processor| processor.match(item) }
      next item_processor.update(item) unless item_processor.nil?
      FALLBACK_PROCESSOR.update(item)
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
