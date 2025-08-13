import 'package:source_span/source_span.dart';

import 'lexer.dart';

abstract class ASTNode {
  final FileSpan span;
  ASTNode(this.span);
}

class WidgetNode extends ASTNode {
  final String name;
  final List<ASTNode> children;
  final Map<String, Expression> properties;
  final List<Expression> positionalArgs;

  WidgetNode(
    this.name,
    this.children,
    this.properties,
    this.positionalArgs,
    FileSpan span,
  ) : super(span);
}

class ClassNode extends ASTNode {
  final String name;
  final List<String> annotations;
  final List<StateVariable> stateVariables;
  final List<MethodNode> methods;

  ClassNode({
    required this.name,
    required this.annotations,
    required this.stateVariables,
    required this.methods,
    required FileSpan span,
  }) : super(span);
}

class StateVariable {
  final String name;
  final String type;
  final String annotation;
  final Expression? initializer;

  StateVariable({
    required this.name,
    required this.type,
    required this.annotation,
    this.initializer,
  });
}

class Expression extends ASTNode {
  Expression(FileSpan span) : super(span);
}

class IdentifierExpression extends Expression {
  final String name;
  IdentifierExpression(this.name, FileSpan span) : super(span);
}

class StringExpression extends Expression {
  final String value;
  StringExpression(this.value, FileSpan span) : super(span);
}

class NumberExpression extends Expression {
  final num value;
  NumberExpression(this.value, FileSpan span) : super(span);
}

class BooleanExpression extends Expression {
  final bool value;
  BooleanExpression(this.value, FileSpan span) : super(span);
}

class AssignmentExpression extends Expression {
  final String target;
  final Expression value;
  AssignmentExpression(this.target, this.value, FileSpan span) : super(span);
}

class ClosureExpression extends Expression {
  final List<String> params;
  final Expression body;
  ClosureExpression(this.params, this.body, FileSpan span) : super(span);
}

class MethodNode extends ASTNode {
  final String name;
  final List<ParameterNode> parameters;
  final ASTNode body;

  MethodNode(this.name, this.parameters, this.body, FileSpan span)
    : super(span);
}

class ParameterNode extends ASTNode {
  final String name;
  final String type;

  ParameterNode(this.name, this.type, FileSpan span) : super(span);
}

class ASTBuilder {
  final List<Token> tokens;
  int _position = 0;

  ASTBuilder(this.tokens);

  ASTNode build() {
    final nodes = <ASTNode>[];

    while (!_isAtEnd()) {
      nodes.add(_parseTopLevel());
    }

    // For now, return the first node
    return nodes.first;
  }

  bool _isAtEnd() =>
      _position >= tokens.length || tokens[_position].type == TokenType.eof;

  Token _peek() => tokens[_position];

  Token _advance() => tokens[_position++];

  bool _check(TokenType type) => !_isAtEnd() && _peek().type == type;

  ASTNode _parseTopLevel() {
    // Skip leading newlines
    while (_check(TokenType.newline)) {
      _advance();
    }
    if (_check(TokenType.annotation) ||
        (_check(TokenType.keyword) && _peek().value == 'class')) {
      return _parseClass();
    }
    return _parseWidget();
  }

  ClassNode _parseClass() {
    final List<String> annotations = <String>[];
    // Collect annotations possibly on multiple lines
    while (_check(TokenType.annotation)) {
      final Token ann = _advance();
      annotations.add(ann.value.substring(1));
      // Optional newline after annotation
      if (_check(TokenType.newline)) _advance();
    }

    // Expect 'class'
    if (!(_check(TokenType.keyword) && _peek().value == 'class')) {
      throw StateError('Expected class keyword');
    }
    _advance();
    // Class name
    final Token nameTok = _expect(TokenType.identifier, name: 'class name');
    final FileSpan classSpan = nameTok.span;
    // EOL
    _consumeOptNewline();

    final List<StateVariable> fields = <StateVariable>[];
    final List<MethodNode> methods = <MethodNode>[];

    // Optional indent for class body
    if (_check(TokenType.indent)) {
      _advance();
      while (!_check(TokenType.dedent) && !_isAtEnd()) {
        // Skip blank lines
        while (_check(TokenType.newline)) _advance();
        if (_check(TokenType.dedent) || _isAtEnd()) break;

        if (_check(TokenType.annotation)) {
          final Token ann = _advance();
          final String annName = ann.value.substring(1);
          if (annName == 'listen' || annName == 'state') {
            fields.add(_parseStateField(annName));
          } else {
            // Unknown annotation: skip rest of line
            _consumeLine();
          }
        } else if (_check(TokenType.keyword) && _peek().value == 'Widget') {
          methods.add(_parseBuildGetter());
        } else {
          // Unknown member: skip
          _consumeLine();
        }
        _consumeOptNewline();
      }
      if (_check(TokenType.dedent)) _advance();
    }

    return ClassNode(
      name: nameTok.value,
      annotations: annotations,
      stateVariables: fields,
      methods: methods,
      span: classSpan,
    );
  }

  WidgetNode _parseWidget() {
    // Widget name
    final Token nameTok = _expectIdentifierLike();
    final String widgetName = nameTok.value;
    final Map<String, Expression> properties = <String, Expression>{};
    final List<ASTNode> children = <ASTNode>[];
    final List<Expression> positionalArgs = <Expression>[];

    // Optional constructor-style positional arguments: Text('World')
    if (_check(TokenType.symbol) && _peek().value == '(') {
      _advance(); // consume '('
      // parse comma-separated expressions until ')'
      while (!_isAtEnd() &&
          !(_check(TokenType.symbol) && _peek().value == ')')) {
        // skip stray commas
        if (_check(TokenType.symbol) && _peek().value == ',') {
          _advance();
          continue;
        }
        final Expression arg = _parseExpression();
        positionalArgs.add(arg);
        // if the expression parser stopped at newline, we are likely malformed inside ()
        // try to consume optional comma
        if (_check(TokenType.symbol) && _peek().value == ',') {
          _advance();
        }
      }
      _expectValue(')');
    }

    _consumeOptNewline();
    // Optional INDENT block for props/children
    if (_check(TokenType.indent)) {
      _advance();
      while (!_check(TokenType.dedent) && !_isAtEnd()) {
        // Skip blank lines
        // Property: identifier ':' expr
        if (_check(TokenType.identifier)) {
          final Token possibleName = _peek();
          // Look ahead for ':' to decide if property or child
          if (_lookaheadIsColon()) {
            _advance(); // consume name
            _expectValue(':');
            final Expression expr = _parseExpression();
            properties[possibleName.value] = expr;
            _consumeOptNewline();
            continue;
          }
        }

        // Cascade style: ..prop: expr OR ..'positional'
        if (_check(TokenType.operator) && _peek().value == '..') {
          _advance(); // consume '..'
          if (_check(TokenType.identifier) && _lookaheadIsColon()) {
            // Property after cascade
            final Token name = _advance();
            _expectValue(':');
            final Expression expr = _parseExpression();
            properties[name.value] = expr;
            _consumeOptNewline();
            continue;
          }
          // Treat the rest of line as a positional argument expression
          final Expression expr = _parseExpression();
          positionalArgs.add(expr);
          _consumeOptNewline();
          continue;
        }

        // Child widget
        final WidgetNode child = _parseWidget();
        children.add(child);
        _consumeOptNewline();
      }
      if (_check(TokenType.dedent)) _advance();
    }

    return WidgetNode(
      widgetName,
      children,
      properties,
      positionalArgs,
      nameTok.span,
    );
  }

  StateVariable _parseStateField(String annotationName) {
    // Parse type tokens until variable name encountered
    final List<String> typeParts = <String>[];
    String nameStr = '';
    // Scan until we find an identifier followed by '=', ';', or newline
    while (!_isAtEnd()) {
      final Token t = _peek();
      if (t.type == TokenType.identifier) {
        final int next = _position + 1;
        if (next < tokens.length) {
          final Token nextTok = tokens[next];
          if (nextTok.value == '=' || nextTok.type == TokenType.newline) {
            nameStr = t.value;
            _advance(); // consume name
            break;
          }
        } else {
          // Identifier at end of stream
          nameStr = t.value;
          _advance();
          break;
        }
      }
      typeParts.add(_advance().value);
    }

    final String typeStr = typeParts.join(' ').trim();

    Expression? initializer;
    // Optional initializer
    if (_check(TokenType.operator) && _peek().value == '=') {
      _advance();
      initializer = _parseExpression();
    }
    _consumeOptNewline();
    return StateVariable(
      name: nameStr,
      type: typeStr.isEmpty ? 'dynamic' : typeStr,
      annotation: annotationName,
      initializer: initializer,
    );
  }

  MethodNode _parseBuildGetter() {
    final Token widgetTok = _advance(); // 'Widget'
    final Token getTok = _expect(TokenType.keyword, name: 'get');
    if (getTok.value != 'get') {
      throw StateError('Expected get after Widget');
    }
    final Token nameTok = _expect(TokenType.identifier, name: 'getter name');
    // Expect =>
    _expect(TokenType.operator, name: '=>');
    // After => newline then widget block
    _consumeOptNewline();
    final WidgetNode root = _parseWidget();
    return MethodNode(nameTok.value, <ParameterNode>[], root, widgetTok.span);
  }

  // Expressions
  Expression _parseExpression() {
    // Closure: (params) => expr
    if (_check(TokenType.symbol) && _peek().value == '(') {
      final Token startTok = _advance();
      final List<String> params = <String>[];
      while (!_isAtEnd() &&
          !(_check(TokenType.symbol) && _peek().value == ')')) {
        if (_check(TokenType.identifier)) {
          params.add(_advance().value);
        } else if (_check(TokenType.symbol) && _peek().value == ',') {
          _advance();
        } else {
          // Skip anything else in params list
          _advance();
        }
      }
      _expectValue(')');
      _expectValue('=>');
      final Expression body = _parseAssignment();
      return ClosureExpression(params, body, startTok.span);
    }

    return _parseAssignment();
  }

  Expression _parseAssignment() {
    final Expression expr = _parseSimpleExpression();

    if (_check(TokenType.operator) && _peek().value == '=') {
      if (expr is IdentifierExpression) {
        _advance();
        final Expression rhs = _parseAssignment();
        return AssignmentExpression(expr.name, rhs, expr.span);
      }
    }
    return expr;
  }

  Expression _parseSimpleExpression() {
    if (_check(TokenType.string)) {
      final Token t = _advance();
      final String raw = t.value;
      // Strip quotes if present
      final String unquoted = raw.length >= 2
          ? raw.substring(1, raw.length - 1)
          : raw;
      return StringExpression(unquoted, t.span);
    }
    if (_check(TokenType.number)) {
      final Token t = _advance();
      final num value = num.parse(t.value);
      return NumberExpression(value, t.span);
    }
    if (_check(TokenType.identifier)) {
      final Token t = _advance();
      if (t.value == 'true' || t.value == 'false') {
        return BooleanExpression(t.value == 'true', t.span);
      }
      return IdentifierExpression(t.value, t.span);
    }
    // Fallback: consume until newline as identifier-like textual expr
    final Token start = _peek();
    final StringBuffer buf = StringBuffer();
    while (!_isAtEnd() && !_check(TokenType.newline)) {
      buf.write(_advance().value);
    }
    return IdentifierExpression(buf.toString(), start.span);
  }

  // Helpers
  Token _expect(TokenType type, {required String name}) {
    if (!_check(type)) {
      throw StateError('Expected $name');
    }
    return _advance();
  }

  void _consumeOptNewline() {
    if (_check(TokenType.newline)) _advance();
  }

  void _consumeLine() {
    while (!_isAtEnd() && !_check(TokenType.newline)) {
      _advance();
    }
    _consumeOptNewline();
  }

  bool _lookaheadIsColon() {
    if (_position + 1 >= tokens.length) return false;
    final Token next = tokens[_position + 1];
    return next.type == TokenType.operator && next.value == ':';
  }

  void _expectValue(String value) {
    if (_check(TokenType.operator) && _peek().value == value) {
      _advance();
      return;
    }
    if (_check(TokenType.symbol) && _peek().value == value) {
      _advance();
      return;
    }
    if (_check(TokenType.keyword) && _peek().value == value) {
      _advance();
      return;
    }
    throw StateError('Expected "$value"');
  }

  Token _expectIdentifierLike() {
    if (_check(TokenType.identifier) ||
        _check(TokenType.keyword) ||
        _check(TokenType.annotation)) {
      return _advance();
    }
    throw StateError('Expected identifier');
  }
}
