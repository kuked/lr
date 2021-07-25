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
      return identifier if alpha?(c)
      return number if digit?(c)

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

    def on_the_way?
      @source.length != @current
    end

    def digit?(c)
      return false if c.nil?
      48 <= c.ord && c.ord <= 57
    end

    def alpha?(c)
      return false if c.nil?
      code = c.ord
      # 'a': 97
      # 'z': 122
      # 'A': 65
      # 'Z': 90
      # '_': 95
      (97 <= code && code <= 122) || (65 <= code && code <= 90) || code == 95
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
      lexeme = @source.slice(@start, @current - @start)
      Token.new(type, lexeme, @line)
    end

    def error_token(message)
      token = Token.new(Token::ERROR, message, @line)
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
          advance while peek != '\n' && on_the_way?
        else
          return
        end
      end
    end

    def string
      while peek != '"' && on_the_way?
        @line += 1 if peek == '\n'
        advance
      end

      return error_token("Unterminated string.") if at_end?

      # The closing quote.
      advance
      make_token(Token::STRING)
    end

    def number
      advance while digit?(peek)

      # Loof for fractional part.
      if peek == '.' && digit?(peek_next)
        advance
        advance while digit?(peek)
      end

      make_token(Token::NUMBER)
    end

    def identifier
      advance while alpha?(peek) || digit?(peek)
      make_token(identifier_type)
    end

    def identifier_type
      lexeme = @source.slice(@start, @current - @start)
      Token::keywords[lexeme]
    end
  end
end
