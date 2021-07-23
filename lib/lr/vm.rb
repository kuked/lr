require_relative 'chunk'
require_relative 'opcode'

module Lr
  class VM
    def initialize
      @ip = 0
    end

    def interpret(chunk)
      @chunk = chunk
      run
    end

    private

    def run
      loop do
        @chunk.disassemble_instruction(@ip)

        instruction = read_code
        case instruction
        when Opcode::OP_CONSTANT
          puts @chunk.read_constant(read_code)
        when Opcode::OP_RETURN
          return 0              # TODO: INTERPRET_OK
        end
      end
    end

    def read_code
      code = @chunk.code[@ip]
      @ip += 1
      code
    end
  end
end
