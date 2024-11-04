import 'package:dpug_analyzer/compiler/lexer.dart';
import 'package:dpug_analyzer/compiler/parser.dart';
import 'package:dpug_analyzer/compiler/source_mapper.dart';

enum NodeType {
  program,
  classDeclaration,
  widgetDeclaration,
  propertyDeclaration,
  stateDeclaration,
  methodDeclaration,
  expression,
  widget,
  property,
  builderExpression,
  templateString,
  lambda,
  stateHook,
  dpugTemplate,
  methodCall,
  propertyAccess,
  parenthesizedExpression,
  argumentList,
  statefulWidget,
  listenVariable,
  methodCascade,
  blockExpression,
  cascadeOperation,
  arrowFunction,
  blockStatement,
  buildMethod,
  stateVariable,
  methodChain,
  assignment,
}

class DPugNode {
  final String type;
  final List<DPugNode> children;
  final Map<String, dynamic> properties;
  final String? value;
  final int line;
  final int column;
  final SourceLocation location;
  final NodeType nodeType;

  const DPugNode({
    required this.type,
    required this.nodeType,
    required this.location,
    this.children = const [],
    this.properties = const {},
    this.value,
    required this.line,
    required this.column,
  });
}

class DPugASTBuilder {
  final List<DPugToken> tokens;
  int _current = 0;
  final ErrorCollector _errors = ErrorCollector();

  DPugASTBuilder(this.tokens);

  bool get isAtEnd => _current >= tokens.length;

  DPugNode buildAST() {
    final declarations = <DPugNode>[];

    while (!isAtEnd && peek()?.type != TokenType.eof) {
      try {
        declarations.add(declaration());
      } catch (e) {
        if (e is ParserError) {
          _errors.addError(e.message, e.location);
          synchronize();
        } else {
          rethrow;
        }
      }
    }

    final firstToken = tokens.firstOrNull ??
        DPugToken(
          type: TokenType.eof,
          lexeme: '',
          line: 1,
          column: 1,
          offset: 0,
        );

    return DPugNode(
      type: 'Program',
      nodeType: NodeType.program,
      children: declarations,
      line: firstToken.line,
      column: firstToken.column,
      location: SourceLocation(
        offset: firstToken.offset,
        line: firstToken.line,
        column: firstToken.column,
        length: tokens.lastOrNull?.offset ??
            0 - firstToken.offset + (tokens.lastOrNull?.lexeme.length ?? 0),
      ),
    );
  }

  void synchronize() {
    advance();

    while (!isAtEnd) {
      if (previous()?.type == TokenType.newLine) return;

      switch (peek()?.type) {
        case TokenType.className:
        case TokenType.annotation:
          return;
        default:
          advance();
      }
    }
  }

  DPugToken? peek() => isAtEnd ? null : tokens[_current];

  DPugToken? previous() => _current > 0 ? tokens[_current - 1] : null;

  DPugToken advance() {
    if (!isAtEnd) _current++;
    return previous()!;
  }

  bool match(TokenType type) {
    if (peek()?.type != type) return false;
    advance();
    return true;
  }

  DPugToken consume(TokenType type, String message) {
    if (peek()?.type == type) return advance();

    final token = peek() ?? previous()!;
    throw ParserError(
      message,
      SourceLocation(
        offset: token.offset,
        line: token.line,
        column: token.column,
        length: token.lexeme.length,
      ),
    );
  }

  DPugNode declaration() {
    if (match(TokenType.annotation)) {
      final annotation = previous()!;
      if (annotation.lexeme == '@stateful') {
        return statefulWidgetDeclaration();
      }
    }

    if (match(TokenType.className)) {
      return classDeclaration();
    }

    throw ParserError(
      'Expected declaration',
      SourceLocation(
        offset: peek()?.offset ?? 0,
        line: peek()?.line ?? 0,
        column: peek()?.column ?? 0,
        length: peek()?.lexeme.length ?? 0,
      ),
    );
  }

  DPugNode annotationDeclaration() {
    final annotation = previous()!;
    final name = consume(TokenType.identifier, "Expected identifier after @");

    return DPugNode(
      type: 'annotation',
      nodeType: NodeType.methodDeclaration,
      value: name.lexeme,
      line: annotation.line,
      column: annotation.column,
      location: SourceLocation(
        offset: annotation.offset,
        line: annotation.line,
        column: annotation.column,
        length: name.offset - annotation.offset + name.lexeme.length,
      ),
    );
  }

  DPugNode classDeclaration() {
    final className = consume(TokenType.identifier, "Expected class name");
    final properties = <DPugNode>[];
    final methods = <DPugNode>[];

    if (match(TokenType.indent)) {
      while (!match(TokenType.dedent) && !isAtEnd) {
        if (match(TokenType.annotation)) {
          methods.add(annotationDeclaration());
        } else {
          properties.add(propertyDeclaration());
        }
      }
    }

    return DPugNode(
      type: 'class',
      nodeType: NodeType.classDeclaration,
      value: className.lexeme,
      children: [...properties, ...methods],
      line: className.line,
      column: className.column,
      location: SourceLocation(
        offset: className.offset,
        line: className.line,
        column: className.column,
        length: className.lexeme.length,
      ),
    );
  }

  DPugNode widgetDeclaration() {
    final widget = consume(TokenType.identifier, "Expected widget name");
    final properties = <DPugNode>[];
    final children = <DPugNode>[];

    while (match(TokenType.property)) {
      properties.add(propertyDeclaration());
    }

    if (match(TokenType.indent)) {
      while (!match(TokenType.dedent) && !isAtEnd) {
        children.add(widgetDeclaration());
      }
    }

    return DPugNode(
      type: widget.lexeme,
      nodeType: NodeType.widget,
      children: children,
      properties: Map.fromEntries(
        properties.map((p) => MapEntry(p.value!, p.properties['value'])),
      ),
      line: widget.line,
      column: widget.column,
      location: SourceLocation(
        offset: widget.offset,
        line: widget.line,
        column: widget.column,
        length: widget.lexeme.length,
      ),
    );
  }

  DPugNode propertyDeclaration() {
    final name = consume(TokenType.property, "Expected property name");
    consume(TokenType.colon, "Expected ':'");
    final value = expression();

    return DPugNode(
      type: 'property',
      nodeType: NodeType.property,
      value: name.lexeme,
      properties: {'value': value},
      line: name.line,
      column: name.column,
      location: SourceLocation(
        offset: name.offset,
        line: name.line,
        column: name.column,
        length: name.lexeme.length,
      ),
    );
  }

  DPugNode expression() {
    if (match(TokenType.string) || match(TokenType.number)) {
      final token = previous()!;
      return DPugNode(
        type: token.type == TokenType.string ? 'String' : 'Number',
        nodeType: NodeType.expression,
        value: token.lexeme,
        line: token.line,
        column: token.column,
        location: SourceLocation(
          offset: token.offset,
          line: token.line,
          column: token.column,
          length: token.lexeme.length,
        ),
      );
    }

    if (match(TokenType.identifier)) {
      final identifier = previous()!;

      // Check for method calls
      if (peek()?.type == TokenType.parenthesis) {
        return methodCallExpression();
      }

      // Check for property access
      if (peek()?.type == TokenType.dot) {
        advance();
        final property =
            consume(TokenType.identifier, "Expected property name");
        return DPugNode(
          type: 'PropertyAccess',
          nodeType: NodeType.propertyAccess,
          value: identifier.lexeme,
          properties: {'property': property.lexeme},
          line: identifier.line,
          column: identifier.column,
          location: SourceLocation(
            offset: identifier.offset,
            line: identifier.line,
            column: identifier.column,
            length: identifier.lexeme.length + property.lexeme.length + 1,
          ),
        );
      }

      return DPugNode(
        type: 'Identifier',
        nodeType: NodeType.expression,
        value: identifier.lexeme,
        line: identifier.line,
        column: identifier.column,
        location: SourceLocation(
          offset: identifier.offset,
          line: identifier.line,
          column: identifier.column,
          length: identifier.lexeme.length,
        ),
      );
    }

    final token = peek() ?? previous()!;
    throw ParserError(
      'Expected expression',
      SourceLocation(
        offset: token.offset,
        line: token.line,
        column: token.column,
        length: token.lexeme.length,
      ),
    );
  }

  DPugNode dpugTemplateDeclaration() {
    consume(TokenType.dpBuilder, "Expected 'DPBuilder'");
    consume(TokenType.parenthesis, "Expected '('");
    consume(TokenType.arrowFunction, "Expected '=>'");
    final template =
        consume(TokenType.templateString, "Expected template string");
    consume(TokenType.parenthesis, "Expected ')'");

    return DPugNode(
      type: 'DPugTemplate',
      nodeType: NodeType.dpugTemplate,
      value: template.lexeme,
      line: template.line,
      column: template.column,
      location: SourceLocation(
        offset: template.offset,
        line: template.line,
        column: template.column,
        length: template.lexeme.length,
      ),
    );
  }

  DPugToken? peekNext() {
    if (_current + 1 >= tokens.length) return null;
    return tokens[_current + 1];
  }

  DPugNode statefulWidgetDeclaration() {
    consume(TokenType.stateful, "Expected @stateful");
    final className = consume(TokenType.identifier, "Expected class name");

    final variables = <DPugNode>[];
    final methods = <DPugNode>[];

    while (peek()?.type == TokenType.annotation) {
      if (match(TokenType.listen)) {
        variables.add(listenVariableDeclaration());
      } else if (match(TokenType.state)) {
        variables.add(stateVariableDeclaration());
      }
    }

    // Parse build method
    consume(TokenType.widget, "Expected Widget");
    consume(TokenType.get, "Expected get");
    consume(TokenType.build, "Expected build");
    consume(TokenType.arrow, "Expected =>");

    final buildBody = widgetDeclaration();

    return DPugNode(
      type: 'StatefulWidget',
      nodeType: NodeType.statefulWidget,
      value: className.lexeme,
      children: [...variables, buildBody],
      line: className.line,
      column: className.column,
      location: SourceLocation(
        offset: className.offset,
        line: className.line,
        column: className.column,
        length: className.lexeme.length,
      ),
    );
  }

  DPugNode listenVariableDeclaration() {
    final type = consume(TokenType.identifier, "Expected type");
    final name = consume(TokenType.identifier, "Expected variable name");
    consume(TokenType.equals, "Expected '='");
    final initialValue = expression();

    return DPugNode(
      type: 'ListenVariable',
      nodeType: NodeType.listenVariable,
      value: name.lexeme,
      properties: {
        'type': type.lexeme,
        'initialValue': initialValue.value,
      },
      line: name.line,
      column: name.column,
      location: SourceLocation(
        offset: name.offset,
        line: name.line,
        column: name.column,
        length: name.lexeme.length,
      ),
    );
  }

  DPugNode stateVariableDeclaration() {
    final type = consume(TokenType.identifier, "Expected type");
    final name = consume(TokenType.identifier, "Expected variable name");
    consume(TokenType.equals, "Expected '='");
    final initialValue = expression();

    return DPugNode(
      type: 'StateVariable',
      nodeType: NodeType.stateDeclaration,
      value: name.lexeme,
      properties: {
        'type': type.lexeme,
        'initialValue': initialValue.value,
      },
      line: name.line,
      column: name.column,
      location: SourceLocation(
        offset: name.offset,
        line: name.line,
        column: name.column,
        length: name.lexeme.length,
      ),
    );
  }

  DPugNode buildMethodDeclaration() {
    consume(TokenType.widget, "Expected Widget type");
    consume(TokenType.get, "Expected get keyword");
    consume(TokenType.build, "Expected build method");
    consume(TokenType.arrow, "Expected =>");

    final body = widgetDeclaration();

    return DPugNode(
      type: 'BuildMethod',
      nodeType: NodeType.buildMethod,
      children: [body],
      line: body.line,
      column: body.column,
      location: body.location,
    );
  }

  DPugNode methodCallExpression() {
    final method = consume(TokenType.identifier, "Expected method name");
    final arguments = <DPugNode>[];

    if (match(TokenType.parenthesis)) {
      while (!match(TokenType.parenthesis) && !isAtEnd) {
        arguments.add(expression());
        if (peek()?.type == TokenType.comma) {
          advance();
        }
      }
    }

    return DPugNode(
      type: 'MethodCall',
      nodeType: NodeType.methodCall,
      value: method.lexeme,
      children: arguments,
      line: method.line,
      column: method.column,
      location: SourceLocation(
        offset: method.offset,
        line: method.line,
        column: method.column,
        length: method.lexeme.length,
      ),
    );
  }

  DPugNode blockExpression() {
    final statements = <DPugNode>[];

    consume(TokenType.indent, "Expected indentation");
    while (!match(TokenType.dedent) && !isAtEnd) {
      statements.add(expression());
      if (peek()?.type == TokenType.newLine) {
        advance();
      }
    }

    return DPugNode(
      type: 'Block',
      nodeType: NodeType.blockExpression,
      children: statements,
      line: statements.first.line,
      column: statements.first.column,
      location: statements.first.location,
    );
  }

  DPugNode cascadeOperation() {
    consume(TokenType.cascade, "Expected '..'");
    final method = methodCallExpression();

    return DPugNode(
      type: 'CascadeOperation',
      nodeType: NodeType.cascadeOperation,
      children: [method],
      line: method.line,
      column: method.column,
      location: method.location,
    );
  }

  DPugNode arrowFunction() {
    final params = parameterList();
    consume(TokenType.arrow, "Expected '=>'");

    final body = match(TokenType.braceLeft) ? blockStatement() : expression();

    return DPugNode(
      type: 'ArrowFunction',
      nodeType: NodeType.arrowFunction,
      children: [...params, body],
      line: body.line,
      column: body.column,
      location: body.location,
    );
  }

  List<DPugNode> parameterList() {
    final params = <DPugNode>[];

    if (match(TokenType.parenthesisLeft)) {
      while (!match(TokenType.parenthesisRight) && !isAtEnd) {
        params.add(parameter());
        if (peek()?.type == TokenType.comma) {
          advance();
        }
      }
    }

    return params;
  }

  DPugNode parameter() {
    final type = match(TokenType.identifier) ? previous()! : null;
    final name = consume(TokenType.identifier, "Expected parameter name");

    return DPugNode(
      type: 'Parameter',
      nodeType: NodeType.expression,
      value: name.lexeme,
      properties: type != null ? {'type': type.lexeme} : {},
      line: name.line,
      column: name.column,
      location: SourceLocation(
        offset: name.offset,
        line: name.line,
        column: name.column,
        length: name.lexeme.length,
      ),
    );
  }

  DPugNode blockStatement() {
    consume(TokenType.braceLeft, "Expected '{'");
    final statements = <DPugNode>[];

    while (!match(TokenType.braceRight) && !isAtEnd) {
      statements.add(statement());
      if (peek()?.type == TokenType.newLine) {
        advance();
      }
    }

    return DPugNode(
      type: 'Block',
      nodeType: NodeType.blockStatement,
      children: statements,
      line: statements.first.line,
      column: statements.first.column,
      location: statements.first.location,
    );
  }

  DPugNode statement() {
    if (match(TokenType.identifier)) {
      final identifier = previous()!;

      // Handle method calls or assignments
      if (peek()?.type == TokenType.parenthesisLeft) {
        return methodCallExpression();
      } else if (peek()?.type == TokenType.equals) {
        return assignmentStatement();
      }

      return DPugNode(
        type: 'Identifier',
        nodeType: NodeType.expression,
        value: identifier.lexeme,
        line: identifier.line,
        column: identifier.column,
        location: SourceLocation(
          offset: identifier.offset,
          line: identifier.line,
          column: identifier.column,
          length: identifier.lexeme.length,
        ),
      );
    }

    return expression();
  }

  DPugNode assignmentStatement() {
    final identifier = previous()!;
    consume(TokenType.equals, "Expected '='");
    final value = expression();

    return DPugNode(
      type: 'Assignment',
      nodeType: NodeType.assignment,
      value: identifier.lexeme,
      properties: {'value': value.value},
      children: [value],
      line: identifier.line,
      column: identifier.column,
      location: SourceLocation(
        offset: identifier.offset,
        line: identifier.line,
        column: identifier.column,
        length: identifier.lexeme.length + 1 + value.location.length,
      ),
    );
  }
}
