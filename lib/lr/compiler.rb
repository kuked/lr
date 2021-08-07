require_relative 'chunk'
require_relative 'scanner'
require_relative 'opcode'
require_relative 'token'

module Lr
  class Compiler
    # Precedence
    PREC_NONE = 0
    PREC_ASSIGNMENT = 1         # =
    PREC_OR = 2                 # or
    PREC_AND = 3                # and
    PREC_EQUALITY = 4           # == !=
    PREC_COMPARISON = 5         # < > <= >=
    PREC_TERM = 6               # + -
    PREC_FACTOR = 7             # * /
    PREC_UNARY = 8              # ! -
    PREC_CALL = 9               # . ()
    PREC_PRIMARY = 10

    def initialize
      @current = nil
      @previous = nil
      @rules = define_rules
    end

    def compile(source)
      @chunk = Chunk.new
      @scanner = Scanner.new(source)

      advance
      expression
      consume(Token::EOF, "Expect end of expression.")
      emit_return

      @chunk.disassemble("code")
      @chunk
    end

    private

    def expression
      parse_precedence(PREC_ASSIGNMENT)
    end

    def grouping
      expression
      consume(Token::RIGHT_PAREN, "Expect ')' after expression.")
    end

    def unary
      type = @previous.type

      # Compile the operand.
      parse_precedence(PREC_UNARY)

      # Emit the operator instruction.
      case type
      when Token::MINUS
        emit_byte(Opcode::OP_NEGATE)
      else
        return
      end
    end

    def binary
      type = @previous.type
      rule = @rules[type]
      parse_precedence(rule[:precedence] + 1)

      case type
      when Token::PLUS
        emit_byte(Opcode::OP_ADD)
      when Token::MINUS
        emit_byte(Opcode::OP_SUBTRACT)
      when Token::STAR
        emit_byte(Opcode::OP_MULTIPLY)
      when Token::SLASH
        emit_byte(Opcode::OP_DIVIDE)
      end
    end

    def literal
      case @previous.type
      when Token::FALSE
        emit_byte(Opcode::OP_FALSE)
      when Token::NIL
        emit_byte(Opcode::OP_NIL)
      when Token::TRUE
        emit_byte(Opcode::OP_TRUE)
      end
    end

    def number
      value = @previous.lexeme.to_f
      emit_constant(Value.number_val(value))
    end

    def advance
      @previous = @current

      loop do
        @current = @scanner.scan_token()
        break if @current.type != Token::ERROR

        error_at_current(@current.lexeme)
      end
    end

    def consume(type, message)
      @current.type == type ? advance : error_at_current(message)
    end

    def error_at_current(message)
    end

    def error(message)
    end

    def error_at(token, message)
      $stderr.print "[line #{token.line}] Error"

      if token.type == Token::EOF
        $stderr.print " at end"
      else
        $stderr.print " at '#{token.lexeme}'"
      end
      $stderr.puts ": #{message}"
    end

    def emit_byte(byte)
      @chunk.write(byte, @previous.line)
    end

    def emit_bytes(byte1, byte2)
      emit_byte(byte1)
      emit_byte(byte2)
    end

    def emit_return
      emit_byte(Opcode::OP_RETURN)
    end

    def emit_constant(value)
      emit_bytes(Opcode::OP_CONSTANT, make_constant(value))
    end

    def make_constant(value)
      @chunk.add_constant(value)
    end

    def parse_precedence(precedence)
      advance
      prefix = @rules[@previous.type][:prefix]
      unless prefix
        # TODO
        # error("Expect expression.")
        return
      end
      self.send(prefix)

      while precedence <= @rules[@current.type][:precedence]
        advance
        infix = @rules[@previous.type][:infix]
        self.send(infix)
      end
    end

    def define_rules
      rules = {
        Token::LEFT_PAREN => { prefix: :grouping, infix: nil, precedence: PREC_NONE },
        Token::RIGHT_PAREN => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::LEFT_BRACE => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::RIGHT_BRACE => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::COMMA => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::DOT => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::MINUS => { prefix: :unary, infix: :binary, precedence: PREC_TERM },
        Token::PLUS => { prefix: nil, infix: :binary, precedence: PREC_TERM },
        Token::SEMICOLON => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::SLASH => { prefix: nil, infix: :binary, precedence: PREC_FACTOR },
        Token::STAR => { prefix: nil, infix: :binary, precedence: PREC_FACTOR },
        Token::BANG => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::BANG_EQUAL => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::EQUAL => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::EQUAL_EQUAL => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::GREATER => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::GREATER_EQUAL => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::LESS => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::LESS_EQUAL => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::IDENTIFIER => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::STRING => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::NUMBER => { prefix: :number, infix: nil, precedence: PREC_NONE },
        Token::AND => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::CLASS => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::ELSE => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::FALSE => { prefix: :literal, infix: nil, precedence: PREC_NONE },
        Token::FOR => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::FUN => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::IF => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::NIL => { prefix: :literal, infix: nil, precedence: PREC_NONE },
        Token::OR => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::PRINT => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::RETURN => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::SUPER => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::THIS => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::TRUE => { prefix: :literal, infix: nil, precedence: PREC_NONE },
        Token::VAR => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::WHILE => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::ERROR => { prefix: nil, infix: nil, precedence: PREC_NONE },
        Token::EOF => { prefix: nil, infix: nil, precedence: PREC_NONE },
      }
      rules.freeze
    end
  end
end
