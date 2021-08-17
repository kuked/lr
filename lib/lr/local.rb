module Lr
  class Local
    attr_reader :name
    attr_accessor :depth

    def initialize(name, depth)
      @name = name
      @depth = depth
    end
  end
end
