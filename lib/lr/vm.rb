require_relative 'chunk'
require_relative 'opcode'
require_relative 'compiler'

module Lr
  class VM
    # interpret result
    INTERPRET_OK = 0
    INTERPRET_COMPILE_ERROR = 1
    INTERPRET_RUNTIME_ERROR = 2

    def initialize
      @ip = 0
      @stack = []
      @compiler = Compiler.new
    end

    def interpret(source)
      @compiler.compile(source)
      INTERPRET_OK
    end

    private

    def run
      loop do
        print '          '
        @stack.each { |slot| print "[ #{slot} ]" }
        puts
        @chunk.disassemble_instruction(@ip)

        instruction = read_code
        case instruction
        when Opcode::OP_CONSTANT
          constant = @chunk.read_constant(read_code)
          push(constant)
        when Opcode::OP_ADD
          binary_op(:+)
        when Opcode::OP_SUBTRACT
          binary_op(:-)
        when Opcode::OP_MULTIPLY
          binary_op(:*)
        when Opcode::OP_DIVIDE
          binary_op(:/)
        when Opcode::OP_NEGATE
          push(-pop())
        when Opcode::OP_RETURN
          puts pop()
          return INTERPRET_OK
        end
      end
    end

    def read_code
      code = @chunk.code[@ip]
      @ip += 1
      code
    end

    def push(value)
      @stack << value
    end

    def pop
      @stack.pop
    end

    def binary_op(operation)
      b = pop()
      a = pop()
      push(a.send(operation, b))
    end
  end
end
