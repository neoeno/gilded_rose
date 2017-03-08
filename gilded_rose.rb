$LOAD_PATH << "lib"

require 'expiry_strategy/normal'
require 'expiry_strategy/eternal'
require 'quality_strategy'
require 'item_processor/can_process_item'
require 'item_processor/specific'
require 'item_processor/fallback'

class GildedRose
  MAX_DATE = Float::INFINITY
  MIN_DATE = -(Float::INFINITY)
  ITEM_PROCESSORS = [
    ItemProcessor::Specific.new("Aged Brie", ExpiryStrategy::Normal.new, QualityStrategy.new(0, 50, {
      (MIN_DATE..-1) => QualityStrategy::Delta.new(2),
      (0..MAX_DATE) => QualityStrategy::Delta.new(1)
    })),
    ItemProcessor::Specific.new("Backstage passes to a TAFKAL80ETC concert", ExpiryStrategy::Normal.new, QualityStrategy.new(0, 50, {
      (0..4) => QualityStrategy::Delta.new(2),
      (5..MAX_DATE) => QualityStrategy::Delta.new(1),
      (MIN_DATE..-1) => QualityStrategy::FixedValue.new(0)
    })),
    ItemProcessor::Specific.new("Sulfuras, Hand of Ragnaros", ExpiryStrategy::Eternal.new, QualityStrategy.new(80, 80, {
      (MIN_DATE..MAX_DATE) => QualityStrategy::Delta.new(0),
    }))
  ]
  FALLBACK_PROCESSOR = ItemProcessor::Fallback.new(ExpiryStrategy::Normal.new, QualityStrategy.new(0, 50, {
    (0..MAX_DATE) => QualityStrategy::Delta.new(-1),
    (MIN_DATE..-1) => QualityStrategy::Delta.new(-2)
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
