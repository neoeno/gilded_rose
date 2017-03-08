module ExpiryStrategy
  class Normal
    def advance(days)
      days - 1
    end
  end
end
