require_relative 'opcode'

module Lr
  module Debug
    def disassemble(message)
      puts "== #{message} =="

      offset = 0
      while offset < @code.length
        offset = disassemble_instruction(offset)
      end
    end

    def disassemble_instruction(offset)
      print format('%04d ', offset)

      if offset > 0 && @lines[offset] == @lines[offset - 1]
        print "   | "
      else
        print format("%4d ", @lines[offset])
      end

      instruction = @code[offset]

      case instruction
      when Opcode::OP_CONSTANT
        constant_instruction("OP_CONSTANT", offset)
      when Opcode::OP_RETURN
        simple_instruction("OP_NAME", offset)
      else
        puts "Unknown opcode #{instruction}"
        offset + 1
      end
    end

    def simple_instruction(name, offset)
      puts name
      offset + 1
    end

    def constant_instruction(name, offset)
      constant = @code[offset + 1]
      puts format("%-16s %4d '#{@constants.values[constant]}'", name, constant)
      offset + 2
    end
  end
end
