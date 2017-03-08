module ItemProcessor
  class Specific
    include CanProcessItem

    def initialize(name, expiry_strategy, quality_strategy)
      @name = name
      super(expiry_strategy, quality_strategy)
    end

    def match(item)
      return item.name == name
    end

    private

    attr_reader :name
  end
end
