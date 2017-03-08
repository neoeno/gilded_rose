class QualityStrategy
  def initialize(min:, max:, ranges:)
    @min = min
    @max = max
    @ranges = ranges
  end

  def advance(item)
    _, change = ranges.find { |range, _| range.include? item.sell_in }
    new_quality = change.apply(item.quality)
    new_quality.clamp(min, max)
  end

  private

  attr_reader :min, :max, :ranges
end
