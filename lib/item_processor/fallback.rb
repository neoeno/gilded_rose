module ItemProcessor
  class Fallback
    include CanProcessItem

    def match(_)
      true
    end
  end
end
