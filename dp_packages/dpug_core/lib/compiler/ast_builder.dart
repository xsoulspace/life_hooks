import 'package:source_span/source_span.dart';

import 'lexer.dart';
import 'plugins/annotation_plugins.dart';

abstract class ASTNode {
  ASTNode(this.span);
  final FileSpan span;
}

class WidgetNode extends ASTNode {
  WidgetNode(
    this.name,
    this.children,
    this.properties,
    this.positionalArgs,
    final FileSpan span,
  ) : super(span);
  final String name;
  final List<ASTNode> children;
  final Map<String, Expression> properties;
  final List<Expression> positionalArgs;
}

class ClassNode extends ASTNode {
  ClassNode({
    required this.name,
    required this.annotations,
    required this.stateVariables,
    required this.methods,
    required final FileSpan span,
  }) : super(span);
  final String name;
  final List<String> annotations;
  final List<StateVariable> stateVariables;
  final List<MethodNode> methods;
}

class StateVariable {
  StateVariable({
    required this.name,
    required this.type,
    required this.annotation,
    this.initializer,
  });
  final String name;
  final String type;
  final String annotation;
  final Expression? initializer;
}

class Expression extends ASTNode {
  Expression(super.span);
}

class IdentifierExpression extends Expression {
  IdentifierExpression(this.name, final FileSpan span) : super(span);
  final String name;
}

class StringExpression extends Expression {
  StringExpression(this.value, final FileSpan span) : super(span);
  final String value;
}

class NumberExpression extends Expression {
  NumberExpression(this.value, final FileSpan span) : super(span);
  final num value;
}

class BooleanExpression extends Expression {
  BooleanExpression(this.value, final FileSpan span) : super(span);
  final bool value;
}

class AssignmentExpression extends Expression {
  AssignmentExpression(this.target, this.value, final FileSpan span)
    : super(span);
  final String target;
  final Expression value;
}

class ClosureExpression extends Expression {
  ClosureExpression(this.params, this.body, final FileSpan span) : super(span);
  final List<String> params;
  final Expression body;
}

class MethodNode extends ASTNode {
  MethodNode(this.name, this.parameters, this.body, final FileSpan span)
    : super(span);
  final String name;
  final List<ParameterNode> parameters;
  final ASTNode body;
}

class ParameterNode extends ASTNode {
  ParameterNode(this.name, this.type, final FileSpan span) : super(span);
  final String name;
  final String type;
}

class ASTBuilder {
  ASTBuilder(this.tokens);
  final List<Token> tokens;
  int _position = 0;

  ASTNode build() {
    print('DEBUG: Starting build, total tokens: ${tokens.length}');
    for (int i = 0; i < tokens.length; i++) {
      print('DEBUG: Token $i: ${tokens[i]}');
    }
    final nodes = <ASTNode>[];

    while (!_isAtEnd()) {
      print(
        'DEBUG: build loop - position: $_position, current token: ${_peek()}',
      );
      final Token currentToken = _peek();

      // Skip structural tokens that shouldn't be parsed as top-level elements
      if (currentToken.type == TokenType.dedent ||
          currentToken.type == TokenType.newline ||
          currentToken.type == TokenType.eof) {
        _advance();
        continue;
      }

      nodes.add(_parseTopLevel());
    }

    print('DEBUG: Built ${nodes.length} nodes');
    // For now, return the first node
    return nodes.first;
  }

  bool _isAtEnd() =>
      _position >= tokens.length || tokens[_position].type == TokenType.eof;

  Token _peek() => tokens[_position];

  Token _advance() => tokens[_position++];

  bool _check(final TokenType type) => !_isAtEnd() && _peek().type == type;

  ASTNode _parseTopLevel() {
    // Skip leading newlines
    while (_check(TokenType.newline)) {
      _advance();
    }
    print('DEBUG: _parseTopLevel - current token: ${_peek()}');
    if (_check(TokenType.annotation) ||
        (_check(TokenType.keyword) && _peek().value == 'class')) {
      print('DEBUG: _parseTopLevel - parsing as class');
      return _parseClass();
    }
    print('DEBUG: _parseTopLevel - parsing as widget');
    return _parseWidget();
  }

  ClassNode _parseClass() {
    final List<String> annotations = <String>[];
    // Collect annotations possibly on multiple lines
    while (_check(TokenType.annotation)) {
      final Token ann = _advance();
      final String annotationName = ann.value.substring(1);
      _validateAnnotation(annotationName, ann);
      annotations.add(annotationName);
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

    // Parse class body - may contain multiple indented blocks
    while (_check(TokenType.indent) && !_isAtEnd()) {
      _advance(); // consume indent
      while (!_isAtEnd()) {
        // Skip blank lines
        while (_check(TokenType.newline)) {
          _advance();
        }

        // If we hit a dedent, we've finished this indentation level
        if (_check(TokenType.dedent)) {
          _advance();
          break;
        }

        if (_isAtEnd()) break;

        if (_check(TokenType.annotation)) {
          final Token ann = _advance();
          final String annName = ann.value.substring(1);
          _validateAnnotation(annName, ann);

          // Use plugin registry to handle field annotation
          final registry = AnnotationPluginRegistry();
          final plugin = registry.getPlugin(annName);
          if (plugin != null) {
            // Let the plugin handle the field parsing
            fields.add(_parseStateField(annName));
          } else {
            throw StateError(
              'Unknown state field annotation "@$annName" at ${ann.span}',
            );
          }
        } else if (_check(TokenType.keyword) && _peek().value == 'Widget') {
          methods.add(_parseBuildGetter());
        } else {
          // Unknown member: skip
          _consumeLine();
        }
        _consumeOptNewline();
      }
      // Skip any newlines between indented blocks
      while (_check(TokenType.newline)) {
        _advance();
      }
    }

    final classNode = ClassNode(
      name: nameTok.value,
      annotations: annotations,
      stateVariables: fields,
      methods: methods,
      span: classSpan,
    );

    // Process class annotations using plugins
    final registry = AnnotationPluginRegistry();
    for (final annotation in annotations) {
      registry.processClassAnnotation(
        annotationName: annotation,
        classNode: classNode,
      );
    }

    // Process field annotations using plugins
    for (final field in fields) {
      registry.processFieldAnnotation(
        annotationName: field.annotation,
        field: field,
        classNode: classNode,
      );
    }

    return classNode;
  }

  WidgetNode _parseWidget() {
    // Skip indentation if present
    if (_check(TokenType.indent)) {
      _advance();
    }

    // Widget name
    print('DEBUG: About to parse widget name, current token: ${_peek()}');
    final Token nameTok = _expectIdentifierLike();
    final String widgetName = nameTok.value;
    _validateWidgetName(widgetName, nameTok);
    print('DEBUG: Successfully parsed widget name: $widgetName');
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
      print(
        'DEBUG: Entering indentation block for widget $widgetName, current token: ${_peek()}',
      );
      while (!_check(TokenType.dedent) && !_isAtEnd()) {
        print(
          'DEBUG: Indentation block iteration for $widgetName, current token: ${_peek()}',
        );
        // Skip blank lines
        if (_check(TokenType.newline)) {
          _advance();
          continue;
        }

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
          print(
            'DEBUG: Processing cascade operator, next token after ..: ${_peek()}',
          );
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

        // Child widget - but only if it's an identifier and not followed by dedent
        if ((_check(TokenType.identifier) || _check(TokenType.keyword)) &&
            !_lookaheadIsDedent()) {
          print(
            'DEBUG: About to parse child widget, current token: ${_peek()}',
          );
          final WidgetNode child = _parseWidget();
          children.add(child);
          _consumeOptNewline();
          continue;
        }

        // If we get here, we have an unexpected token
        print(
          'DEBUG: Unexpected token in indentation block: ${_peek()}, breaking',
        );
        // If it's a dedent token, we're done with this indentation level
        if (_check(TokenType.dedent)) {
          break;
        }
        // Otherwise, skip this token and continue
        _advance();
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

  StateVariable _parseStateField(final String annotationName) {
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
    // Expect 'get' keyword
    if (!(_check(TokenType.keyword) && _peek().value == 'get')) {
      throw StateError('Expected get after Widget');
    }
    final Token getTok = _advance(); // consume 'get'
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
  Token _expect(final TokenType type, {required final String name}) {
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

  bool _lookaheadIsDedent() {
    if (_position + 1 >= tokens.length) return false;
    final Token next = tokens[_position + 1];
    return next.type == TokenType.dedent;
  }

  void _expectValue(final String value) {
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
    final String caller = StackTrace.current.toString().split('\n')[1];
    print('DEBUG: _expectIdentifierLike called from $caller');
    print(
      'DEBUG: _expectIdentifierLike - current token: ${_peek()}, position: $_position',
    );
    if (_check(TokenType.identifier) ||
        _check(TokenType.keyword) ||
        _check(TokenType.annotation)) {
      return _advance();
    }
    print('DEBUG: Expected identifier but got: ${_peek()}');
    throw StateError('Expected identifier');
  }

  /// Validate that an annotation is supported
  void _validateAnnotation(final String annotationName, final Token token) {
    final registry = AnnotationPluginRegistry();

    // Check if annotation is supported by any plugin
    if (!registry.isAnnotationSupported(annotationName)) {
      // For now, allow unknown annotations to pass through
      // In the future, this could be configurable (strict mode vs permissive mode)
      print('Warning: Unknown annotation "@$annotationName" at ${token.span}');
      print('No plugin registered to handle this annotation.');
      print(
        'Consider creating a custom plugin or using a built-in annotation.',
      );
    }
  }

  /// Validate that a widget name is a valid Dart identifier
  void _validateWidgetName(final String widgetName, final Token token) {
    // Basic validation: must be a valid Dart identifier
    if (widgetName.isEmpty) {
      throw StateError('Empty widget name at ${token.span}');
    }

    // Check if it starts with a letter or underscore
    if (!RegExp('^[a-zA-Z_]').hasMatch(widgetName)) {
      throw StateError(
        'Invalid widget name "$widgetName" at ${token.span}. Widget names must start with a letter or underscore.',
      );
    }

    // Check if the rest contains only letters, digits, or underscores
    if (!RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(widgetName)) {
      throw StateError(
        'Invalid widget name "$widgetName" at ${token.span}. Widget names can only contain letters, digits, and underscores.',
      );
    }
  }
}
