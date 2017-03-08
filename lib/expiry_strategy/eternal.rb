module ExpiryStrategy
  class Eternal
    def advance(item)
      item.sell_in
    end
  end
end
