require_relative 'scanner'
require_relative 'token'

module Lr
  class Compiler
    def compile(source)
      @scanner = Scanner.new(source)

      line = -1
      loop do
        token = @scanner.scan_token()
        if token.line != line
          print format("%4d ", token.line)
          line = token.line
        else
          print '   | '
        end
        puts format("%2d '%s'", token.type, token.lexeme)

        break if token.type == Token::EOF
      end
    end
  end
end
