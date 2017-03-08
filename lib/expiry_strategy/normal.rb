module ExpiryStrategy
  class Normal
    def advance(item)
      item.sell_in - 1
    end
  end
end
