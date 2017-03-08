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

module ItemProcessor
  def initialize(expiry_strategy)
    @expiry_strategy = expiry_strategy
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

  attr_reader :expiry_strategy

  def update_expiry(item)
    item.sell_in = expiry_strategy.advance(item.sell_in)
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
    if item.sell_in >= 0
      item.quality += 1
    else
      item.quality += 2
    end

    item.quality = [50, item.quality].min
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
    expiring_soon = (0..4).include?(item.sell_in)

    if expiring_soon
      item.quality += 2
    else
      item.quality += 1
    end

    if item.sell_in < 0
      item.quality = 0
    end

    item.quality = [50, item.quality].min
  end
end

class RegularOldItemProcessor
  include ItemProcessor

  def match(_)
    true
  end

  private

  def update_quality(item)
    if item.sell_in >= 0
      item.quality -= 1
    else
      item.quality -= 2
    end

    item.quality = [0, item.quality].max
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
  end
end

class GildedRose
  ITEM_PROCESSORS = [
    AgedBrieItemProcessor.new(NormalExpiryStrategy),
    BackstagePassesItemProcessor.new(NormalExpiryStrategy),
    SulfurasItemProcessor.new(EternalExpiryStrategy)
  ]
  FALL_BACK_PROCESSOR = RegularOldItemProcessor.new(NormalExpiryStrategy)

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
