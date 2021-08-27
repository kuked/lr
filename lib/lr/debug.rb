require_relative "opcode"

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
      print format("%04d ", offset)

      if offset > 0 && @lines[offset] == @lines[offset - 1]
        print "   | "
      else
        print format("%4d ", @lines[offset])
      end

      instruction = @code[offset]

      case instruction
      when Opcode::OP_CONSTANT
        constant_instruction("OP_CONSTANT", offset)
      when Opcode::OP_NIL
        simple_instruction("OP_NIL", offset)
      when Opcode::OP_FALSE
        simple_instruction("OP_FALSE", offset)
      when Opcode::OP_TRUE
        simple_instruction("OP_TRUE", offset)
      when Opcode::OP_POP
        simple_instruction("OP_POP", offset)
      when Opcode::OP_GET_LOCAL
        byte_instruction("OP_GET_LOCAL", offset)
      when Opcode::OP_SET_LOCAL
        byte_instruction("OP_SET_LOCAL", offset)
      when Opcode::OP_GET_GLOBAL
        constant_instruction("OP_GET_GLOBAL", offset)
      when Opcode::OP_DEFINE_GLOBAL
        constant_instruction("OP_DEFINE_GLOBAL", offset)
      when Opcode::OP_SET_GLOBAL
        constant_instruction("OP_SET_GLOBAL", offset)
      when Opcode::OP_EQUAL
        return simple_instruction("OP_EQUAL", offset)
      when Opcode::OP_GREATER
        return simple_instruction("OP_GREATER", offset)
      when Opcode::OP_LESS
        return simple_instruction("OP_LESS", offset)
      when Opcode::OP_ADD
        simple_instruction("OP_ADD", offset)
      when Opcode::OP_SUBTRACT
        simple_instruction("OP_SUBTRACT", offset)
      when Opcode::OP_MULTIPLY
        simple_instruction("OP_MULTIPLY", offset)
      when Opcode::OP_DIVIDE
        simple_instruction("OP_DIVIDE", offset)
      when Opcode::OP_NOT
        simple_instruction("OP_NOT", offset)
      when Opcode::OP_NEGATE
        simple_instruction("OP_NEGATE", offset)
      when Opcode::OP_PRINT
        simple_instruction("OP_PRINT", offset)
      when Opcode::OP_JUMP
        jump_instruction("OP_JUMP", 1, offset)
      when Opcode::OP_JUMP_IF_FALSE
        jump_instruction("OP_JUMP_IF_FALSE", 1, offset)
      when Opcode::OP_RETURN
        simple_instruction("OP_RETURN", offset)
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
      puts format("%-16s %4d '#{@constants[constant].value}'", name, constant)
      offset + 2
    end

    def byte_instruction(name, offset)
      slot = @code[offset + 1]
      puts format("%-16s %4d", name, slot)
      offset + 2
    end

    def jump_instruction(name, sign, offset)
      jump = @code[offset + 1]
      puts format("%-16s %4d -> %d", name, offset, offset + 2 + sign * jump)
      offset + 2
    end
  end
end
