module NormalExpiryStrategy
  def self.advance(days)
    days - 1
  end
end

module EternalExpiryStrategy
  def self.advance(days)
    days
  end
end

class QualityStrategy
  def initialize(min, max, ranges_to_deltas)
    @min = min
    @max = max
    @ranges_to_deltas = ranges_to_deltas
  end

  def advance(item)
    _, delta = ranges_to_deltas.find { |range, _| range.include? item.sell_in }
    new_quality = item.quality + delta
    new_quality.clamp(min, max)
  end

  private

  attr_reader :min, :max, :ranges_to_deltas
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

  def update_quality(item)
    item.quality = QualityStrategy.new(0, 50, {
      (-1000..-1) => 2,
      (0..1000) => 1
    }).advance(item)
  end
end

class BackstagePassesItemProcessor
  include ItemProcessor
  ITEM_NAME_MATCHER = "Backstage passes to a TAFKAL80ETC concert"

  private

  def item_name
    ITEM_NAME_MATCHER
  end

  def update_quality(item)
    item.quality = QualityStrategy.new(0, 50, {
      (0..4) => 2,
      (5..1000) => 1,
      (-1000..-1) => -(item.quality)
    }).advance(item)
  end
end

class RegularOldItemProcessor
  include ItemProcessor

  def match(_)
    true
  end

  private

  def update_quality(item)
    item.quality = QualityStrategy.new(0, 50, {
      (0..1000) => -1,
      (-1000..-1) => -2
    }).advance(item)
  end
end

class SulfurasItemProcessor
  include ItemProcessor
  ITEM_NAME_MATCHER = "Sulfuras, Hand of Ragnaros"

  private

  def item_name
    ITEM_NAME_MATCHER
  end

  def update_quality(item)
    item.quality = QualityStrategy.new(80, 80, {
      (-1000..1000) => 0,
    }).advance(item)
  end
end

class GildedRose
  ITEM_PROCESSORS = [
    AgedBrieItemProcessor.new(NormalExpiryStrategy, nil),
    BackstagePassesItemProcessor.new(NormalExpiryStrategy, nil),
    SulfurasItemProcessor.new(EternalExpiryStrategy, nil)
  ]
  FALL_BACK_PROCESSOR = RegularOldItemProcessor.new(NormalExpiryStrategy, nil)

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
