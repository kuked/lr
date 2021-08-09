require_relative "chunk"
require_relative "scanner"
require_relative "opcode"
require_relative "token"
require_relative "object"

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

      until match(Token::EOF)
        declaration
      end

      emit_return

      @chunk.disassemble("code")
      @chunk
    end

    private

    def expression
      parse_precedence(PREC_ASSIGNMENT)
    end

    def print_statement
      expression
      consume(Token::SEMICOLON, "Expect ';' after value.")
      emit_byte(Opcode::OP_PRINT)
    end

    def declaration
      statement
    end

    def statement
      print_statement if match(Token::PRINT)
    end

    def grouping
      expression
      consume(Token::RIGHT_PAREN, "Expect ')' after expression.")
    end

    def unary
      type = @previous.type

      # Compile the operand.
      parse_precedence(PREC_UNARY)
      n
      # Emit the operator instruction.
      case type
      when Token::BANG
        emit_byte(Opcode::OP_NOT)
      when Token::MINUS
        emit_byte(Opcode::OP_NEGATE)
      else
        return
      end
    end

    def binary
      type = @previous.type
      rule = @rules[type]
      parse_precedence(rule.precedence + 1)

      case type
      when Token::BANG_EQUAL
        emit_bytes(Opcode::OP_EQUAL, Opcode::OP_NOT)
      when Token::EQUAL_EQUAL
        emit_byte(Opcode::OP_EQUAL)
      when Token::GREATER
        emit_byte(Opcode::OP_GREATER)
      when Token::GREATER_EQUAL
        emit_bytes(Opcode::OP_LESS, Opcode::OP_NOT)
      when Token::LESS
        emit_byte(Opcode::OP_LESS)
      when Token::LESS_EQUAL
        emit_bytes(Opcode::OP_GREATER, Opcode::OP_NOT)
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

    def string
      value = @previous.lexeme[1..-2] # trim quotation marks
      emit_constant(Value.obj_val(Lr::Object.string_obj(value)))
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

    def match(type)
      return false unless check(type)
      advance
      true
    end

    def check(type)
      @current.type == type
    end

    def error_at_current(message)
      # TODO: write this.
    end

    def error(message)
      # TODO: write this.
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
      prefix = @rules[@previous.type].prefix
      unless prefix
        # TODO
        # error("Expect expression.")
        return
      end
      self.send(prefix)

      while precedence <= @rules[@current.type].precedence
        advance
        infix = @rules[@previous.type].infix
        self.send(infix)
      end
    end

    def define_rules
      rule = Struct.new(:prefix, :infix, :precedence)
      rules = {
        Token::LEFT_PAREN => rule.new(:grouping, nil, PREC_NONE),
        Token::RIGHT_PAREN => rule.new(nil, nil, PREC_NONE),
        Token::LEFT_BRACE => rule.new(nil, nil, PREC_NONE),
        Token::RIGHT_BRACE => rule.new(nil, nil, PREC_NONE),
        Token::COMMA => rule.new(nil, nil, PREC_NONE),
        Token::DOT => rule.new(nil, nil, PREC_NONE),
        Token::MINUS => rule.new(:unary, :binary, PREC_TERM),
        Token::PLUS => rule.new(nil, :binary, PREC_TERM),
        Token::SEMICOLON => rule.new(nil, nil, PREC_NONE),
        Token::SLASH => rule.new(nil, :binary, PREC_FACTOR),
        Token::STAR => rule.new(nil, :binary, PREC_FACTOR),
        Token::BANG => rule.new(:unary, nil, PREC_NONE),
        Token::BANG_EQUAL => rule.new(nil, :binary, PREC_EQUALITY),
        Token::EQUAL => rule.new(nil, nil, PREC_NONE),
        Token::EQUAL_EQUAL => rule.new(nil, :binary, PREC_EQUALITY),
        Token::GREATER => rule.new(nil, :binary, PREC_COMPARISON),
        Token::GREATER_EQUAL => rule.new(nil, :binary, PREC_COMPARISON),
        Token::LESS => rule.new(nil, :binary, PREC_COMPARISON),
        Token::LESS_EQUAL => rule.new(nil, :binary, PREC_COMPARISON),
        Token::IDENTIFIER => rule.new(nil, nil, PREC_NONE),
        Token::STRING => rule.new(:string, nil, PREC_NONE),
        Token::NUMBER => rule.new(:number, nil, PREC_NONE),
        Token::AND => rule.new(nil, nil, PREC_NONE),
        Token::CLASS => rule.new(nil, nil, PREC_NONE),
        Token::ELSE => rule.new(nil, nil, PREC_NONE),
        Token::FALSE => rule.new(:literal, nil, PREC_NONE),
        Token::FOR => rule.new(nil, nil, PREC_NONE),
        Token::FUN => rule.new(nil, nil, PREC_NONE),
        Token::IF => rule.new(nil, nil, PREC_NONE),
        Token::NIL => rule.new(:literal, nil, PREC_NONE),
        Token::OR => rule.new(nil, nil, PREC_NONE),
        Token::PRINT => rule.new(nil, nil, PREC_NONE),
        Token::RETURN => rule.new(nil, nil, PREC_NONE),
        Token::SUPER => rule.new(nil, nil, PREC_NONE),
        Token::THIS => rule.new(nil, nil, PREC_NONE),
        Token::TRUE => rule.new(:literal, nil, PREC_NONE),
        Token::VAR => rule.new(nil, nil, PREC_NONE),
        Token::WHILE => rule.new(nil, nil, PREC_NONE),
        Token::ERROR => rule.new(nil, nil, PREC_NONE),
        Token::EOF => rule.new(nil, nil, PREC_NONE),
      }
      rules.freeze
    end
  end
end
