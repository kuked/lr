module Lr
  class Value
    attr_reader :value

    # types of value
    VAL_BOOL   = 0
    VAL_NIL    = 1
    VAL_NUMBER = 2

    def initialize(value, type)
      @value = value
      @type = type
    end

    def self.bool_val(value)
      self.new(vlaue, VAL_BOOL)
    end

    def self.nil_val
      self.new(0, VAL_NIL)
    end

    def self.number_val(value)
      self.new(value, VAL_NUMBER)
    end
  end
end
