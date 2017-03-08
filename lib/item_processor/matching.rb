module ItemProcessor
  class Matching
    include CanProcessItem

    def initialize(pattern, expiry_strategy, quality_strategy)
      @pattern = pattern
      super(expiry_strategy, quality_strategy)
    end

    def match(item)
      return pattern.match?(item.name)
    end

    private

    attr_reader :pattern
  end
end
