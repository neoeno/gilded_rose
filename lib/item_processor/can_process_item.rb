module ItemProcessor
  module CanProcessItem
    def initialize(expiry_strategy, quality_strategy)
      @expiry_strategy = expiry_strategy
      @quality_strategy = quality_strategy
    end

    def update(item)
      update_expiry(item)
      update_quality(item)
      item
    end

    private

    attr_reader :expiry_strategy, :quality_strategy

    def update_expiry(item)
      item.sell_in = expiry_strategy.advance(item)
    end

    def update_quality(item)
      item.quality = quality_strategy.advance(item)
    end
  end
end
