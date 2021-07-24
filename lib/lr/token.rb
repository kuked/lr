module Lr
  class Token
    attr_accessor :type, :start, :length, :line, :message

    def initialize(type)
      @type = type
    end

    # single-character tokens.
    LEFT_PAREN = 0
    RIGHT_PAREN = 1
    LEFT_BRACE = 2
    RIGHT_BRACE = 3
    COMMA = 4
    DOT = 5
    MINUS = 6
    PLUS = 7
    SEMICOLON = 8
    SLASH = 9
    STAR = 10

    # one or two character tokens.
    BANG = 20
    BANG_EQUAL = 21
    EQUAL = 22
    EQUAL_EQUAL = 23
    GREATER = 24
    GREATER_EQUAL = 25
    LESS = 26
    LESS_EQUAL = 27

    # literals.
    IDENTIFIER = 30
    STRING = 31
    NUMBER = 32

    # keywords.
    AND = 40
    CLASS = 41
    ELSE = 42
    FALSE = 43
    FOR = 44
    FUN = 45
    IF = 46
    NIL = 47
    OR = 48
    PRINT = 49
    RETURN = 50
    SUPER = 51
    THIS = 52
    TRUE = 53
    VAR = 54
    WHILE = 55

    ERROR = 90
    EOF = 91
  end
end
