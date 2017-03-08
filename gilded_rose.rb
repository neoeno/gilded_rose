class AgedBrieItem
  def initialize
  end

  def update(item)
    update_expiry(item)
    update_quality(item)
    item
  end

  private

  def update_expiry(item)
    item.sell_in = item.sell_in - 1
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

class GildedRose

  def initialize(items)
    @items = items
  end

  def update_quality__aged_brie(item)
    AgedBrieItem.new.update(item)
  end

  def update_quality__backstage_passes(item)
    item.sell_in = item.sell_in - 1
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

  def update_quality__sulfuras(item)
  end

  def update_quality__unspecial(item)
    item.sell_in = item.sell_in - 1

    if item.sell_in >= 0
      item.quality -= 1
    else
      item.quality -= 2
    end

    item.quality = [0, item.quality].max
  end

  def update_quality()
    @items.each do |item|
      next update_quality__aged_brie(item) if item.name == "Aged Brie"
      next update_quality__backstage_passes(item) if item.name == "Backstage passes to a TAFKAL80ETC concert"
      next update_quality__sulfuras(item) if item.name == "Sulfuras, Hand of Ragnaros"
      update_quality__unspecial(item)
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
