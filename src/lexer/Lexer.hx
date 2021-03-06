package lexer;

import lexer.Keyword.getKeywordType;
import lexer.Keyword.isKeyword;
import lexer.LexerHelper.isLinebreak;
import lexer.LexerHelper.isNumber;
import lexer.LexerHelper.isAscii;

class Lexer {
    private final code:String;
    var currentChar = " ";
    var position = 0;

    public function new(code:String) {
        this.code = code;
    }

    function readChar() {
        currentChar = if (position >= code.length) {
            "\u{0}";
        } else {
            code.charAt(position);
        }

        position++;

        eatComment();
    }

    function peekChar():String {
        return (position >= code.length) ? "\u{0}" : code.charAt(position);
    }

    function readIdent():String {
        final startPosition = position;

        while (isAscii(peekChar()) || peekChar() == "_") {
            readChar();
        }

        return code.substring(startPosition - 1, position);
    }

    function readNumber():String {
        final startPosition = position;

        while (isNumber(peekChar())) {
            readChar();
        }

        return code.substring(startPosition - 1, position);
    }

    function eatWhitespace() {
        while (currentChar == " " || isLinebreak(currentChar) || currentChar == "\t") {
            readChar();
        }
    }

    function eatComment() {
        if (currentChar == "/" && peekChar() == "/") {
            while (!isLinebreak(currentChar) && currentChar != "\u{0}") {
                readChar();
            }
        }
    }

    public function tokenize() {
        while (currentChar != "\u{0}") {
            final token = readToken();
            trace(token.toString());
        }
    }

    public function peekToken():Token {
        final lastPosition = position;
        final lastChar = currentChar;
        final token = readToken();
        position = lastPosition;
        currentChar = lastChar;

        return token;
    }

    public function readToken():Token {
        readChar();
        eatWhitespace();

        return switch (currentChar) {
            case ":": new Token(Colon, currentChar);
            case ";": new Token(Semicolon, currentChar);
            case "{": new Token(LBrace, currentChar);
            case "}": new Token(RBrace, currentChar);
            case "(": new Token(LParen, currentChar);
            case ")": new Token(RParen, currentChar);
            case "[": new Token(LBrack, currentChar);
            case "]": new Token(RBrack, currentChar);
            case "+": new Token(Plus, currentChar);
            case "-": new Token(Minus, currentChar);
            case "*": new Token(Asterisk, currentChar);
            case "/": new Token(Slash, currentChar);
            case "=": 
                if (peekChar() == "=") {
                    readChar();
                    new Token(Equals, "==");
                } else {
                    new Token(Assign, currentChar);
                }
            case "!":
                if (peekChar() == "=") {
                    readChar();
                    new Token(NotEquals, "!=");
                } else {
                    new Token(Illegal, currentChar);
                }
            case "<": new Token(LessThan, currentChar);
            case ">": new Token(GreaterThan, currentChar);
            case "\u{0}": new Token(Eof, currentChar);
            default:
                if (isNumber(currentChar)) {
                    final number = readNumber();
                    return new Token(Integer, number);
                }

                if (isAscii(currentChar)) {
                    final ident = readIdent();

                    return if (isKeyword(ident)) {
                        new Token(getKeywordType(ident), ident);
                    } else {
                        new Token(Ident, ident);
                    }
                }

                return new Token(Illegal, currentChar);
        }
    }
}