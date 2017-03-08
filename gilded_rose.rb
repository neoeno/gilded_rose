class GildedRose

  def initialize(items)
    @items = items
  end

  def update_quality__aged_brie(item)
    if item.quality < 50
      item.quality = item.quality + 1
    end
    item.sell_in = item.sell_in - 1
    if item.sell_in < 0
      if item.quality < 50
        item.quality = item.quality + 1
      end
    end
  end

  def update_quality__backstage_passes(item)
    item.sell_in = item.sell_in - 1

    if item.quality < 50 && !((0..4).include?(item.sell_in))
      item.quality += 1
    end

    if item.quality < 50 && (0..4).include?(item.sell_in)
      item.quality += 1
    end

    if item.quality < 49 && (0..4).include?(item.sell_in)
      item.quality += 2
    end

    if item.sell_in < 0
      item.quality = 0
    end
  end

  def update_quality__sulfuras(item)
    # Nothing!
  end

  def update_quality__unspecial(item)
    if item.quality > 0
      item.quality = item.quality - 1
    end
    item.sell_in = item.sell_in - 1
    if item.sell_in < 0
      if item.quality > 0
        item.quality = item.quality - 1
      end
    end
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
