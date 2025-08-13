import 'package:code_builder/code_builder.dart' as cb;
import 'package:source_span/source_span.dart';

import 'ast_builder.dart';
import 'package:dpug_code_builder/src/builders/dart_widget_code_generator.dart';
import 'package:dpug_code_builder/src/specs/annotation_spec.dart';
import 'package:dpug_code_builder/src/specs/class_spec.dart';
import 'package:dpug_code_builder/src/specs/expression_spec.dart';
import 'package:dpug_code_builder/src/specs/method_spec.dart';
import 'package:dpug_code_builder/src/specs/state_field_spec.dart';

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
    final List<DpugStateFieldSpec> fields = <DpugStateFieldSpec>[];
    for (final StateVariable f in node.stateVariables) {
      fields.add(DpugStateFieldSpec(
        name: f.name,
        type: f.type,
        annotation: DpugAnnotationSpec(name: f.annotation),
        initializer: f.initializer != null
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

    final DpugClassSpec classSpec = DpugClassSpec(
      name: node.name,
      stateFields: fields,
      methods: [
        DpugMethodSpec.getter(
          name: 'build',
          returnType: 'Widget',
          body: DpugExpressionSpec.code('return $widgetExpr;'),
        ),
      ],
    );

    final DartWidgetCodeGenerator generator = DartWidgetCodeGenerator();
    return generator.generateStatefulWidget(classSpec);
  }

  // Widget emission
  String _widgetToDartExpr(WidgetNode node) {
    final Map<String, String> props = <String, String>{};
    node.properties.forEach((String key, Expression value) {
      props[key] = _exprToDart(value);
    });

    // Positional arguments (including cascade positional style)
    final List<String> posArgs = <String>[];
    for (final Expression a in node.positionalArgs) {
      posArgs.add(_exprToDart(a));
    }

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

    final String positional =
        posArgs.isEmpty ? '' : posArgs.map((e) => e).join(', ');

    final String combined;
    if (named.isEmpty && positional.isEmpty) {
      combined = '';
    } else if (named.isEmpty) {
      combined = positional;
    } else if (positional.isEmpty) {
      combined = '\n      $named\n    ';
    } else {
      combined = '$positional,\n      $named\n    ';
    }

    return '${node.name}(${combined.isEmpty ? '' : '\n  '}$combined${combined.isEmpty ? '' : '\n'})';
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
