import 'package:code_builder/code_builder.dart' as cb;
import 'package:source_span/source_span.dart';

import 'ast_builder.dart';
import 'dart_code_builder.dart';

/// Transforms parsed AST into Dart source using [DpugCodeBuilder].
class AstToDart {
  final SourceFile file;
  AstToDart(this.file);

  /// Generate formatted Dart code from a top-level AST node.
  String generate(ASTNode node) {
    if (node is ClassNode) return _classToDart(node);
    if (node is WidgetNode) {
      final String expr = _widgetToDartExpr(node);
      return 'Widget build(BuildContext context) {\n  return $expr;\n}';
    }
    throw StateError('Unsupported AST node: ${node.runtimeType}');
  }

  String _classToDart(ClassNode node) {
    final List<StateField> fields = <StateField>[];
    for (final StateVariable f in node.stateVariables) {
      fields.add(StateField(
        name: f.name,
        type: f.type,
        annotation: f.annotation,
        initialValue: f.initializer != null
            ? cb.CodeExpression(cb.Code(_exprToDart(f.initializer!)))
            : null,
      ));
    }

    // Find build method widget body
    WidgetNode? buildRoot;
    for (final MethodNode m in node.methods) {
      if (m.name == 'build' && m.body is WidgetNode) {
        buildRoot = m.body as WidgetNode;
        break;
      }
    }
    if (buildRoot == null) {
      throw StateError('Missing build method');
    }

    final String widgetExpr = _widgetToDartExpr(buildRoot);
    final cb.Code buildBody = cb.Code('return $widgetExpr;');

    final DpugCodeBuilder builder = DpugCodeBuilder();
    return builder.buildStatefulWidget(
      className: node.name,
      stateFields: fields,
      buildMethod: buildBody,
    );
  }

  // Widget emission
  String _widgetToDartExpr(WidgetNode node) {
    final Map<String, String> props = <String, String>{};
    node.properties.forEach((String key, Expression value) {
      props[key] = _exprToDart(value);
    });

    // Children sugar
    if (node.children.isNotEmpty) {
      if (node.children.length == 1) {
        props['child'] = _widgetToDartExpr(node.children.first as WidgetNode);
      } else {
        final List<String> items = <String>[];
        for (final ASTNode c in node.children) {
          items.add(_widgetToDartExpr(c as WidgetNode));
        }
        props['children'] =
            '[\n${items.map((e) => '        $e,').join('\n')}\n      ]';
      }
    }

    final String named = props.isEmpty
        ? ''
        : props.entries.map((e) => '${e.key}: ${e.value}').join(',\n      ');

    final String args = named.isEmpty ? '' : '\n      $named\n    ';
    return '${node.name}(${args.isEmpty ? '' : '\n  '}$args${args.isEmpty ? '' : '\n'})';
  }

  // Expressions to Dart source
  String _exprToDart(Expression e) {
    if (e is StringExpression) return "'${_escapeString(e.value)}'";
    if (e is NumberExpression) return e.value.toString();
    if (e is BooleanExpression) return e.value ? 'true' : 'false';
    if (e is IdentifierExpression) return e.name;
    if (e is AssignmentExpression) {
      return '${e.target} = ${_exprToDart(e.value)}';
    }
    if (e is ClosureExpression) {
      final String params = e.params.join(', ');
      return '($params) => ${_exprToDart(e.body)}';
    }
    return '';
  }

  String _escapeString(String input) =>
      input.replaceAll('\\', r'\\').replaceAll("'", r"\'");
}
