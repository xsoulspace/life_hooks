import 'package:source_span/source_span.dart';

enum TokenType {
  identifier,
  indent,
  dedent,
  newline,
  annotation,
  keyword,
  operator,
  string,
  number,
  symbol,
  eof
}

class Token {
  final TokenType type;
  final String value;
  final FileSpan span;

  Token(this.type, this.value, this.span);

  @override
  String toString() => '$type($value)';
}

class Lexer {
  final String source;
  int _position = 0;
  int _line = 1;
  int _column = 0;
  List<int> _indentStack = [0];

  Lexer(this.source);

  List<Token> tokenize() {
    final tokens = <Token>[];
    Token? token;

    while ((token = _nextToken()) != null) {
      tokens.add(token!);
    }

    // Add dedents at EOF if needed
    while (_indentStack.last > 0) {
      tokens.add(_createToken(TokenType.dedent, ''));
      _indentStack.removeLast();
    }

    tokens.add(_createToken(TokenType.eof, ''));
    return tokens;
  }

  Token? _nextToken() {
    _skipWhitespace();

    if (_position >= source.length) return null;

    final char = source[_position];

    if (char == '@') return _scanAnnotation();
    if (_isIdentifierStart(char)) return _scanIdentifier();
    if (_isDigit(char)) return _scanNumber();
    if (char == '"' || char == "'") return _scanString();

    return _scanOperator();
  }

  Token _createToken(TokenType type, String value) {
    final start = SourceLocation(_position, line: _line, column: _column);
    final end = SourceLocation(_position + value.length,
        line: _line, column: _column + value.length);
    return Token(type, value,
        SourceFile.fromString(source).span(start.offset, end.offset));
  }

  // Helper methods
  bool _isIdentifierStart(String char) => RegExp(r'[a-zA-Z_]').hasMatch(char);

  bool _isDigit(String char) => RegExp(r'[0-9]').hasMatch(char);

  void _skipWhitespace() {
    while (_position < source.length &&
        RegExp(r'[ \t]').hasMatch(source[_position])) {
      _position++;
      _column++;
    }
  }

  // Scanning methods
  Token _scanAnnotation() {
    final start = _position;
    _position++; // Skip @

    while (_position < source.length && _isIdentifierStart(source[_position])) {
      _position++;
    }

    return _createToken(
        TokenType.annotation, source.substring(start, _position));
  }

  Token _scanIdentifier() {
    // Implementation
    throw UnimplementedError();
  }

  Token _scanNumber() {
    // Implementation
    throw UnimplementedError();
  }

  Token _scanString() {
    // Implementation
    throw UnimplementedError();
  }

  Token _scanOperator() {
    // Implementation
    throw UnimplementedError();
  }
}
