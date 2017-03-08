module ExpiringItem
  private def update_expiry(item)
    item.sell_in = item.sell_in - 1
  end
end

module EternalItem
  private def update_expiry(item)
  end
end

class AbstractItemProcessor
  def self.match(item)
    return item.name == item_name
  end

  def update(item)
    update_expiry(item)
    update_quality(item)
    item
  end

  private

  def update_expiry
    raise NotImplementedError
  end

  def update_quality
    raise NotImplementedError
  end
end

class AgedBrieItemProcessor < AbstractItemProcessor
  include ExpiringItem
  ITEM_NAME_MATCHER = "Aged Brie"

  private

  def self.item_name
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

class BackstagePassesItemProcessor < AbstractItemProcessor
  include ExpiringItem
  ITEM_NAME_MATCHER = "Backstage passes to a TAFKAL80ETC concert"

  private

  def self.item_name
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

class RegularOldItemProcessor < AbstractItemProcessor
  include ExpiringItem

  def self.match(_)
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

class SulfurasItemProcessor < AbstractItemProcessor
  include EternalItem
  ITEM_NAME_MATCHER = "Sulfuras, Hand of Ragnaros"

  private

  def self.item_name
    ITEM_NAME_MATCHER
  end

  def update_quality(item)
  end
end

class GildedRose
  ITEM_PROCESSORS = [
    AgedBrieItemProcessor,
    BackstagePassesItemProcessor,
    SulfurasItemProcessor,
    RegularOldItemProcessor
  ]

  def initialize(items)
    @items = items
  end

  def update_quality()
    @items.each do |item|
      item_processor = ITEM_PROCESSORS.find { |processor| processor.match(item) }
      item_processor.new.update(item)
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
