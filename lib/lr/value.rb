module Lr
  class Value
    attr_reader :count, :values

    def initialize
      @count  = 0
      @values = []
    end

    def write(value)
      @values[@count] = value
      @count += 1
    end
  end
end
