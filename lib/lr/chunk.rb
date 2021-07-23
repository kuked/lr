require_relative 'value'
require_relative 'debug'

module Lr
  class Chunk
    include Debug

    attr_reader :code

    def initialize
      @count = 0
      @code = []
      @lines = []
      @constants = Lr::Value.new
    end

    def write(byte, line)
      @code[@count] = byte
      @lines[@count] = line
      @count += 1
    end

    def add_constant(value)
      @constants.write(value)
      @constants.count - 1
    end

    def read_constant(index)
      @constants.values[index]
    end
  end
end
