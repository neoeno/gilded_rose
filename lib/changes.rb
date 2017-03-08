module Changes
  class Add < Struct.new(:value)
    def apply(n)
      n + value
    end
  end

  class Set < Struct.new(:value)
    def apply(n)
      value
    end
  end
end
