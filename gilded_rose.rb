$LOAD_PATH << "lib"

require 'expiry_strategy/normal'
require 'expiry_strategy/eternal'
require 'quality_strategy'
require 'changes'
require 'item_processor/can_process_item'
require 'item_processor/specific'
require 'item_processor/matching'
require 'item_processor/fallback'

class GildedRose
  MAX_DATE = Float::INFINITY
  MIN_DATE = -(Float::INFINITY)

  AGED_BRIE_PROCESSOR = ItemProcessor::Specific.new(
    "Aged Brie",
    ExpiryStrategy::Normal.new,
    QualityStrategy.new(
      min: 0,
      max: 50,
      ranges: {
        (MIN_DATE..-1) => Changes::Add.new(2),
        (0..MAX_DATE) => Changes::Add.new(1)
      }))

  BACKSTAGE_PASSES_PROCESSOR = ItemProcessor::Specific.new(
    "Backstage passes to a TAFKAL80ETC concert",
    ExpiryStrategy::Normal.new,
    QualityStrategy.new(
      min: 0,
      max: 50,
      ranges: {
        (0..4) => Changes::Add.new(3),
        (5..9) => Changes::Add.new(2),
        (9..MAX_DATE) => Changes::Add.new(1),
        (MIN_DATE..-1) => Changes::Set.new(0)
      }))

  SULFURAS_PROCESSOR = ItemProcessor::Specific.new(
    "Sulfuras, Hand of Ragnaros",
    ExpiryStrategy::Eternal.new,
    QualityStrategy.new(
      min: 80,
      max: 80,
      ranges: {
        (MIN_DATE..MAX_DATE) => Changes::Add.new(0),
      }))

  CONJURED_PROCESSOR = ItemProcessor::Matching.new(
    /^Conjured/,
    ExpiryStrategy::Normal.new,
    QualityStrategy.new(
      min: 0,
      max: 50,
      ranges: {
        (0..MAX_DATE) => Changes::Add.new(-2),
        (MIN_DATE..-1) => Changes::Add.new(-4)
      }))

  FALLBACK_PROCESSOR = ItemProcessor::Fallback.new(
    ExpiryStrategy::Normal.new,
    QualityStrategy.new(
      min: 0,
      max: 50,
      ranges: {
        (0..MAX_DATE) => Changes::Add.new(-1),
        (MIN_DATE..-1) => Changes::Add.new(-2)
      }))

  ITEM_PROCESSORS = [AGED_BRIE_PROCESSOR, BACKSTAGE_PASSES_PROCESSOR, SULFURAS_PROCESSOR, CONJURED_PROCESSOR]

  def initialize(items)
    @items = items
  end

  def update_quality
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
