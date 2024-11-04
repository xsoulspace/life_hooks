class DPugToken {
  final TokenType type;
  final String lexeme;
  final dynamic literal;
  final int line;
  final int column;
  final int offset;

  const DPugToken({
    required this.type,
    required this.lexeme,
    this.literal,
    required this.line,
    required this.column,
    required this.offset,
  });
}

enum TokenType {
  className,
  widget,
  get,
  build,
  extendsKeyword,
  annotation,
  identifier,
  parenthesisLeft,
  parenthesisRight,
  arrow,
  indent,
  dedent,
  newLine,
  string,
  number,
  operator,
  property,
  function,
  colon,
  eof,
  templateString,
  lambda,
  hookWidget,
  state,
  dpBuilder,
  templateStringStart,
  templateStringEnd,
  templateStringContent,
  arrowFunction,
  parenthesis,
  comma,
  dot,
  braceLeft,
  braceRight,
  equals,
  stateful,
  listen,
  cascade,
  blockExpression,
  methodChain,
}

class DPugLexer {
  final String source;
  int _position = 0;
  int _start = 0;
  int _line = 1;
  int _column = 1;
  final List<int> _indentStack = [0];

  DPugLexer(this.source);

  bool get isAtEnd => _position >= source.length;

  List<DPugToken> tokenize() {
    final tokens = <DPugToken>[];

    while (!isAtEnd) {
      _start = _position;
      final token = nextToken();
      if (token != null) {
        tokens.add(token);
      }
    }

    // Handle remaining dedents
    while (_indentStack.length > 1) {
      _indentStack.removeLast();
      tokens.add(DPugToken(
        type: TokenType.dedent,
        lexeme: '',
        line: _line,
        column: _column,
        offset: _position,
      ));
    }

    // Add EOF token
    tokens.add(DPugToken(
      type: TokenType.eof,
      lexeme: '',
      line: _line,
      column: _column,
      offset: _position,
    ));

    return tokens;
  }

  DPugToken? nextToken() {
    skipWhitespace();
    _start = _position;

    if (isAtEnd) return null;

    final char = peek();

    switch (char) {
      case '\n':
        return handleNewLine();
      case '@':
        return scanAnnotation();
      case '"':
      case "'":
        return scanString();
      case ':':
        advance();
        return makeToken(TokenType.colon);
      case '.':
        if (peekNext() == '.') {
          advance();
          advance();
          return makeToken(TokenType.cascade);
        }
        advance();
        return makeToken(TokenType.dot);
      case '=':
        if (peekNext() == '>') {
          advance();
          advance();
          return makeToken(TokenType.arrow);
        }
        advance();
        return makeToken(TokenType.equals);
      case '(':
        advance();
        return makeToken(TokenType.parenthesisLeft);
      case ')':
        advance();
        return makeToken(TokenType.parenthesisRight);
      case '{':
        advance();
        return makeToken(TokenType.braceLeft);
      case '}':
        advance();
        return makeToken(TokenType.braceRight);
      case ',':
        advance();
        return makeToken(TokenType.comma);
    }

    if (isDigit(char)) {
      return scanNumber();
    }

    if (isAlpha(char)) {
      return scanIdentifierOrKeyword();
    }

    advance();
    return null;
  }

  DPugToken scanProperty() {
    while (isAlphaNumeric(peek())) {
      advance();
    }

    return DPugToken(
      type: TokenType.property,
      lexeme: source.substring(_start, _position),
      line: _line,
      column: _column - (_position - _start),
      offset: _start,
    );
  }

  String peek() => isAtEnd ? '\0' : source[_position];

  String peekNext() =>
      _position + 1 >= source.length ? '\0' : source[_position + 1];

  String advance() {
    _position++;
    _column++;
    return source[_position - 1];
  }

  bool match(String expected) {
    if (isAtEnd) return false;
    if (source[_position] != expected) return false;

    _position++;
    _column++;
    return true;
  }

  void skipWhitespace() {
    while (!isAtEnd) {
      final char = peek();
      switch (char) {
        case ' ':
        case '\r':
        case '\t':
          advance();
          break;
        case '/':
          if (peekNext() == '/') {
            while (peek() != '\n' && !isAtEnd) advance();
          } else {
            return;
          }
          break;
        default:
          return;
      }
    }
  }

  DPugToken scanAnnotation() {
    advance(); // Consume @

    while (isAlphaNumeric(peek())) {
      advance();
    }

    final text = source.substring(_start + 1, _position); // Skip @
    switch (text) {
      case 'stateful':
        return makeToken(TokenType.stateful);
      case 'listen':
        return makeToken(TokenType.listen);
      case 'state':
        return makeToken(TokenType.state);
      default:
        return makeToken(TokenType.annotation);
    }
  }

  DPugToken scanString() {
    final quote = advance(); // Consume opening quote

    while (peek() != quote && !isAtEnd) {
      if (peek() == '\n') _line++;
      advance();
    }

    if (isAtEnd) {
      throw LexerError('Unterminated string', _line);
    }

    advance(); // Consume closing quote

    return DPugToken(
      type: TokenType.string,
      lexeme: source.substring(_start, _position),
      literal: source.substring(_start + 1, _position - 1), // Remove quotes
      line: _line,
      column: _column - (_position - _start),
      offset: _start,
    );
  }

  DPugToken handleNewLine() {
    _line++;
    _column = 1;
    advance();

    int indent = 0;
    while (peek() == ' ' || peek() == '\t') {
      indent++;
      advance();
    }

    final lastIndent = _indentStack.last;
    if (indent > lastIndent) {
      _indentStack.add(indent);
      return makeToken(TokenType.indent);
    } else if (indent < lastIndent) {
      _indentStack.removeLast();
      return makeToken(TokenType.dedent);
    }

    return makeToken(TokenType.newLine);
  }

  DPugToken scanIdentifier() {
    while (isAlphaNumeric(peek())) {
      advance();
    }

    final text = source.substring(_start, _position);
    final type = _keywords[text] ?? TokenType.identifier;

    return DPugToken(
      type: type,
      lexeme: text,
      line: _line,
      column: _column - text.length,
      offset: _start,
    );
  }

  DPugToken scanNumber() {
    while (isDigit(peek())) {
      advance();
    }

    // Look for decimal point
    if (peek() == '.' && isDigit(peekNext())) {
      advance(); // Consume the '.'

      while (isDigit(peek())) {
        advance();
      }
    }

    return makeToken(TokenType.number);
  }

  bool isAlpha(String c) {
    return (c.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
            c.codeUnitAt(0) <= 'z'.codeUnitAt(0)) ||
        (c.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
            c.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) ||
        c == '_';
  }

  bool isDigit(String c) {
    return c.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
        c.codeUnitAt(0) <= '9'.codeUnitAt(0);
  }

  bool isAlphaNumeric(String c) => isAlpha(c) || isDigit(c);

  DPugToken? scanTemplateString() {
    if (match("'''")) {
      _start = _position;
      while (!isAtEnd && !match("'''")) {
        if (peek() == '\n') {
          _line++;
          _column = 1;
        } else {
          _column++;
        }
        advance();
      }

      return DPugToken(
        type: TokenType.templateString,
        lexeme: source.substring(_start, _position - 3),
        line: _line,
        column: _column,
        offset: _start,
      );
    }
    return null;
  }

  DPugToken? scanArrowFunction() {
    if (match('=>')) {
      return DPugToken(
        type: TokenType.arrowFunction,
        lexeme: '=>',
        line: _line,
        column: _column - 2,
        offset: _start,
      );
    }
    return null;
  }

  DPugToken? scanCascade() {
    if (match('..')) {
      return DPugToken(
        type: TokenType.cascade,
        lexeme: '..',
        line: _line,
        column: _column - 2,
        offset: _start,
      );
    }
    return null;
  }

  DPugToken makeToken(TokenType type) {
    return DPugToken(
      type: type,
      lexeme: source.substring(_start, _position),
      line: _line,
      column: _column - (_position - _start),
      offset: _start,
    );
  }

  DPugToken scanIdentifierOrKeyword() {
    while (isAlphaNumeric(peek())) {
      advance();
    }

    final text = source.substring(_start, _position);
    final type = _keywords[text] ?? TokenType.identifier;

    return makeToken(type);
  }
}

class LexerError extends Error {
  final String message;
  final int line;

  LexerError(this.message, this.line);

  @override
  String toString() => 'Error at line $line: $message';
}

final _keywords = {
  'class': TokenType.className,
  'fn': TokenType.function,
  'extends': TokenType.extendsKeyword,
  'Widget': TokenType.widget,
  'get': TokenType.get,
  'build': TokenType.build,
};
