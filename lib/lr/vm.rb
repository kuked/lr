require_relative "chunk"
require_relative "opcode"
require_relative "compiler"

module Lr
  class VM
    # interpret result
    INTERPRET_OK = 0
    INTERPRET_COMPILE_ERROR = 1
    INTERPRET_RUNTIME_ERROR = 2

    def initialize
      @stack = []
      @compiler = Compiler.new
    end

    def interpret(source)
      # TODO: catch exception
      @chunk = @compiler.compile(source)
      run
    end

    private

    def run
      @ip = 0
      loop do
        print " " * 10
        @stack.each { |slot| print "[ #{slot.printable} ]" }
        puts
        @chunk.disassemble_instruction(@ip)

        instruction = read_code
        case instruction
        when Opcode::OP_CONSTANT
          constant = @chunk.read_constant(read_code)
          push(constant)
        when Opcode::OP_NIL
          push(Value.nil_val)
        when Opcode::OP_FALSE
          push(Value.bool_val(false))
        when Opcode::OP_TRUE
          push(Value.bool_val(true))
        when Opcode::OP_EQUAL
          b = pop
          a = pop
          push(Value.bool_val(a.eql?(b)))
        when Opcode::OP_GREATER
          binary_op(:bool_val, :>)
        when Opcode::OP_LESS
          binary_op(:bool_val, :<)
        when Opcode::OP_ADD
          if peek(0).string? && peek(1).string?
            concatenate
          elsif peek(0).number? && peek(1).number?
            b = pop().value
            a = pop().value
            push(Value.number_val(a + b))
          end
        when Opcode::OP_SUBTRACT
          binary_op(:number_val, :-)
        when Opcode::OP_MULTIPLY
          binary_op(:number_val, :*)
        when Opcode::OP_DIVIDE
          binary_op(:number_val, :/)
        when Opcode::OP_NOT
          push(Value.bool_val(pop.falsey?))
        when Opcode::OP_NEGATE
          unless peek(0).number?
            # TODO: runtimeerror
            return INTERPRET_RUNTIME_ERROR
          end
          push(Value.number_val(-pop.value))
        when Opcode::OP_PRINT
          puts pop.printable
        when Opcode::OP_RETURN
          # Exit interpreter.
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

    def peek(distance)
      @stack[-1 - distance]
    end

    def binary_op(type, operation)
      if !peek(0).number? || !peek(1).number?
        # TODO: runtimeerror
      end
      b = pop.value
      a = pop.value

      c = a.send(operation, b)
      push(Value.send(type, c))
    end

    def concatenate
      b = pop.string
      a = pop.string
      push(Value.obj_val(Lr::Object.string_obj(a + b)))
    end
  end
end
