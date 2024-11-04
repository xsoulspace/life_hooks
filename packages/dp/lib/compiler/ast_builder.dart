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

  WidgetNode(this.name, this.children, this.properties, FileSpan span)
      : super(span);
}

class ClassNode extends ASTNode {
  final String name;
  final List<String> annotations;
  final List<StateVariable> stateVariables;
  final List<MethodNode> methods;

  ClassNode(
      {required this.name,
      required this.annotations,
      required this.stateVariables,
      required this.methods,
      required FileSpan span})
      : super(span);
}

class StateVariable {
  final String name;
  final String type;
  final String annotation;
  final Expression? initializer;

  StateVariable(
      {required this.name,
      required this.type,
      required this.annotation,
      this.initializer});
}

class Expression extends ASTNode {
  Expression(FileSpan span) : super(span);
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
    if (_check(TokenType.annotation)) {
      return _parseClass();
    }
    return _parseWidget();
  }

  ClassNode _parseClass() {
    // Implementation
    throw UnimplementedError();
  }

  WidgetNode _parseWidget() {
    // Implementation
    throw UnimplementedError();
  }
}
