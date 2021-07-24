require_relative 'token'

module Lr
  class Scanner
    def initialize(source)
      @source = source
      @start = 0
      @current = 0
      @line = 1
    end

    def scan_token
      skip_whitespace

      @start = @current
      return make_token(Token::EOF) if at_end?

      c = advance

      case c
      when '('
        return make_token(Token::LEFT_PAREN)
      when ')'
        return make_token(Token::RIGHT_PAREN)
      when '{'
        return make_token(Token::LEFT_BRACE)
      when '}'
        return make_token(Token::RIGHT_BRACE)
      when ';'
        return make_token(Token::SEMICOLON)
      when ','
        return make_token(Token::COMMA)
      when '.'
        return make_token(Token::DOT)
      when '-'
        return make_token(Token::MINUS)
      when '+'
        return make_token(Token::PLUS)
      when '/'
        return make_token(Token::SLASH)
      when '*'
        return make_token(Token::STAR)
      when '!'
        return make_token(match('=') ? Token::BANG_EQUAL : Token::BANG)
      when '='
        return make_token(match('=') ? Token::EQUAL_EQUAL : Token::EQUAL)
      when '<'
        return make_token(match('=') ? Token::LESS_EQUAL : Token::LESS)
      when '>'
        return make_token(match('>') ? Token::GREATER_EQUAL : Token::GREATER)
      when '"'
        return string
      end

      return error_token('Unexpected character.')
    end

    private

    def at_end?
      @source.length == @current
    end

    def match(expected)
      return false if at_end?
      return false if current != expecetd
      @current += 1
      true
    end

    def advance
      @current += 1
      @source[@current - 1]
    end

    def make_token(type)
      token = Token.new(type)
      token.start = @start
      token.length = @current - @start
      token.line = @line
      token
    end

    def error_token(message)
      token = Token.new(Token::ERROR)
      token.start = @start
      token.length = message.length
      token.line = @line
      token.message = message
      token
    end

    def current
      @source[@current - 1]
    end

    def peek
      @source[@current]
    end

    def peek_next
      return nil if at_end?
      @source[@current + 1]
    end

    def skip_whitespace
      loop do
        c = peek
        case c
        when ' ', '\r', '\t'
          advance
        when '\n'
          @line += 1
          advance
        when '/'
          return unless peek_next == '/'
          advance while peek != '\n' && !ad_end?
        else
          return
        end
      end
    end

    def string
      while peek != '"' && !at_end?
        @line += 1 if peek == '\n'
        advance
      end

      return error_token("Unterminated string.") if at_end?

      # The closing quote.
      advance
      make_token(Token::STRING)
    end
  end
end
