module Lr
  class Object
    attr_reader :object, :type

    # types of object
    OBJ_STRING = 0

    def initialize(object, type)
      @object = object
      @type = type
    end

    def string?
      @type == OBJ_STRING
    end

    def eql?(other)
      result = if @type != other.type
          false
        else
          case @type
          when OBJ_STRING
            @object == other.object
          else
            false
          end
        end
      result
    end

    def printable
      case @type
      when OBJ_STRING
        @object
      end
    end

    def self.string_obj(value)
      self.new(value, OBJ_STRING)
    end
  end
end
