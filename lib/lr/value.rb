require_relative "object"

module Lr
  class Value
    attr_reader :value, :type

    # types of value
    VAL_BOOL = 0
    VAL_NIL = 1
    VAL_NUMBER = 2
    VAL_OBJ = 3

    def initialize(value, type)
      @value = value
      @type = type
    end

    def bool?
      @type == VAL_BOOL
    end

    def nil?
      @type == VAL_NIL
    end

    def number?
      @type == VAL_NUMBER
    end

    def obj?
      @type == VAL_OBJ
    end

    def string?
      obj? && @value.string?
    end

    def string
      @value.object
    end

    def falsey?
      nil? || (bool? && !@value)
    end

    def eql?(other)
      result = if @type != other.type
          false
        else
          case @type
          when VAL_BOOL, VAL_NUMBER
            @value == other.value
          when VAL_NIL
            true
          when VAL_OBJ
            @value.eql?(other.value)
          else
            false
          end
        end
      result
    end

    def printable
      case @type
      when VAL_BOOL
        @value ? "true" : "false"
      when VAL_NIL
        "nil"
      when VAL_NUMBER
        sprintf("%g", @value)
      when VAL_OBJ
        @value.printable
      end
    end

    def self.bool_val(value)
      self.new(value, VAL_BOOL)
    end

    def self.nil_val
      self.new(0, VAL_NIL)
    end

    def self.number_val(value)
      self.new(value, VAL_NUMBER)
    end

    def self.obj_val(value)
      self.new(value, VAL_OBJ)
    end
  end
end
