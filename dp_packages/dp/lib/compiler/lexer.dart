import 'package:source_span/source_span.dart';

/// Token types for the DPug lexer.
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

/// Represents a lexical token with source span.
class Token {
  final TokenType type;
  final String value;
  final FileSpan span;

  Token(this.type, this.value, this.span);

  @override
  String toString() => '$type($value)';
}

/// Simple indentation-aware lexer for DPug syntax.
///
/// Supports:
/// - Annotations (e.g., `@stateful`, `@listen`)
/// - Keywords (`class`, `get`)
/// - Identifiers (including dotted like `GridView.builder`)
/// - Numbers, strings, operators, symbols
/// - Newlines with INDENT/DEDENT tokens
class Lexer {
  final String source;

  final SourceFile _file;
  int _index = 0;
  int _line = 1;
  int _column = 0;
  bool _atLineStart = true;
  final List<int> _indentStack = <int>[0];

  Lexer(this.source) : _file = SourceFile.fromString(source);

  /// Tokenize the entire source into a flat list.
  List<Token> tokenize() {
    final List<Token> tokens = <Token>[];

    while (!_isEOF) {
      if (_atLineStart) {
        _emitIndentDedent(tokens);
      }

      final Token? token = _nextToken();
      if (token != null) tokens.add(token);
    }

    // Flush any remaining dedents at EOF.
    while (_indentStack.length > 1) {
      tokens.add(_makeToken(TokenType.dedent, '', _index, _index));
      _indentStack.removeLast();
    }

    tokens.add(_makeToken(TokenType.eof, '', _index, _index));
    return tokens;
  }

  // Core scanning
  Token? _nextToken() {
    if (_isEOF) return null;

    final String ch = _peekChar();

    // Newline
    if (ch == '\n') {
      final int start = _index;
      _advance();
      _line += 1;
      _column = 0;
      _atLineStart = true;
      return _makeToken(TokenType.newline, '\n', start, _index);
    }

    // Carriage return (treat as whitespace)
    if (ch == '\r') {
      _advance();
      return _nextToken();
    }

    // Skip spaces/tabs mid-line
    if (ch == ' ' || ch == '\t') {
      _skipInlineWhitespace();
      return _nextToken();
    }

    // Annotation
    if (ch == '@') return _scanAnnotation();

    // String literal
    if (ch == '"' || ch == "'") return _scanString();

    // Number literal
    if (_isDigit(ch)) return _scanNumber();

    // Identifier or keyword (including dotted identifiers)
    if (_isIdentifierStart(ch)) return _scanIdentifierOrKeyword();

    // Operators and symbols
    return _scanOperatorOrSymbol();
  }

  // Indentation handling
  void _emitIndentDedent(List<Token> out) {
    // Measure leading indentation (spaces/tabs) from current index
    int i = _index;
    int width = 0;
    while (i < source.length) {
      final String ch = source[i];
      if (ch == ' ') {
        width += 1;
        i += 1;
      } else if (ch == '\t') {
        width += 2; // Treat a tab as two spaces for simplicity
        i += 1;
      } else if (ch == '\r') {
        // ignore
        i += 1;
      } else {
        break;
      }
    }

    // Update index/column to skip indentation chars
    _column += (i - _index);
    _index = i;

    final int current = _indentStack.last;
    if (width > current) {
      _indentStack.add(width);
      out.add(_makeToken(TokenType.indent, '', _index, _index));
    } else if (width < current) {
      while (_indentStack.length > 1 && width < _indentStack.last) {
        _indentStack.removeLast();
        out.add(_makeToken(TokenType.dedent, '', _index, _index));
      }
    }

    _atLineStart = false;
  }

  // Scanners
  Token _scanAnnotation() {
    final int start = _index;
    _advance(); // '@'
    while (!_isEOF && _isIdentifierPart(_peekChar())) {
      _advance();
    }
    final String text = source.substring(start, _index);
    return _makeToken(TokenType.annotation, text, start, _index);
  }

  Token _scanIdentifierOrKeyword() {
    final int start = _index;
    _advance();
    while (!_isEOF) {
      final String ch = _peekChar();
      if (_isIdentifierPart(ch) || ch == '.') {
        _advance();
      } else {
        break;
      }
    }
    final String text = source.substring(start, _index);
    final bool isKeyword = text == 'class' || text == 'get' || text == 'Widget';
    return _makeToken(isKeyword ? TokenType.keyword : TokenType.identifier,
        text, start, _index);
  }

  Token _scanNumber() {
    final int start = _index;
    while (!_isEOF && _isDigit(_peekChar())) {
      _advance();
    }
    if (!_isEOF && _peekChar() == '.') {
      _advance();
      while (!_isEOF && _isDigit(_peekChar())) {
        _advance();
      }
    }
    final String text = source.substring(start, _index);
    return _makeToken(TokenType.number, text, start, _index);
  }

  Token _scanString() {
    final int start = _index;
    final String quote = _peekChar();
    _advance();
    final StringBuffer buf = StringBuffer(quote);
    while (!_isEOF) {
      final String ch = _peekChar();
      buf.write(ch);
      _advance();
      if (ch == quote) break;
      if (ch == '\\' && !_isEOF) {
        // escape next
        buf.write(_peekChar());
        _advance();
      }
    }
    final String text = source.substring(start, _index);
    return _makeToken(TokenType.string, text, start, _index);
  }

  Token _scanOperatorOrSymbol() {
    final int start = _index;
    final String ch = _peekChar();
    // Two-char operators first
    if (_match('=>')) {
      return _makeToken(TokenType.operator, '=>', start, _index);
    }
    if (_match('..')) {
      return _makeToken(TokenType.operator, '..', start, _index);
    }

    // Single char
    _advance();
    final TokenType type;
    switch (ch) {
      case ':':
      case '=':
      case '+':
      case '-':
      case '*':
      case '/':
        type = TokenType.operator;
        break;
      case '(':
      case ')':
      case '{':
      case '}':
      case '[':
      case ']':
      case ',':
      case '<':
      case '>':
        type = TokenType.symbol;
        break;
      default:
        // Treat unknown as symbol to avoid crashes
        type = TokenType.symbol;
    }
    return _makeToken(type, ch, start, _index);
  }

  // Utilities
  bool get _isEOF => _index >= source.length;

  String _peekChar() => source[_index];

  void _advance() {
    _index += 1;
    _column += 1;
  }

  void _skipInlineWhitespace() {
    while (!_isEOF) {
      final String ch = _peekChar();
      if (ch == ' ' || ch == '\t') {
        _advance();
      } else {
        break;
      }
    }
  }

  bool _match(String s) {
    if (_index + s.length > source.length) return false;
    if (source.substring(_index, _index + s.length) == s) {
      _index += s.length;
      _column += s.length;
      return true;
    }
    return false;
  }

  bool _isIdentifierStart(String ch) => RegExp(r'[A-Za-z_]').hasMatch(ch);
  bool _isIdentifierPart(String ch) => RegExp(r'[A-Za-z0-9_]').hasMatch(ch);
  bool _isDigit(String ch) => RegExp(r'[0-9]').hasMatch(ch);

  Token _makeToken(TokenType type, String value, int start, int end) {
    final SourceLocation startLoc =
        SourceLocation(start, line: _line, column: _column - (end - start));
    final SourceLocation endLoc =
        SourceLocation(end, line: _line, column: _column);
    return Token(type, value, _file.span(startLoc.offset, endLoc.offset));
  }
}
