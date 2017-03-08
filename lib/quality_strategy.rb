class QualityStrategy
  Delta = Struct.new(:delta)
  FixedValue = Struct.new(:value)
  
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
