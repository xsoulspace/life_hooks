import 'package:dpug_code_builder/dpug_code_builder.dart';
import 'package:source_span/source_span.dart';

import 'ast_builder.dart';

/// Transforms parsed AST into Dart source using [DpugCodeBuilder].
class AstToDart {
  AstToDart(this.file);
  final SourceFile file;

  /// Generate formatted Dart code from a top-level AST node.
  String generate(final ASTNode node) {
    if (node is ClassNode) return _classToDart(node);
    if (node is WidgetNode) {
      final String expr = _widgetToDartExpr(node);
      return 'Widget build(BuildContext context) {\n  return $expr;\n}';
    }
    if (node is Expression) {
      // For simple expressions, just return the expression as Dart code
      return _exprToDart(node);
    }
    throw StateError('Unsupported AST node: ${node.runtimeType}');
  }

  String _classToDart(final ClassNode node) {
    final List<DpugStateFieldSpec> fields = <DpugStateFieldSpec>[];
    for (final StateVariable f in node.stateVariables) {
      fields.add(
        DpugStateFieldSpec(
          name: f.name,
          type: f.type,
          annotation: DpugAnnotationSpec(name: f.annotation),
          initializer: f.initializer != null
              ? DpugExpressionSpec.reference(_exprToDart(f.initializer!))
              : null,
        ),
      );
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

    final DpugClassSpec classSpec = DpugClassSpec(
      name: node.name,
      stateFields: fields,
      methods: [
        DpugMethodSpec.getter(
          name: 'build',
          returnType: 'Widget',
          body: DpugCodeSpec('return $widgetExpr;'),
        ),
      ],
    );

    final DartWidgetCodeGenerator generator = DartWidgetCodeGenerator();
    return generator.generateStatefulWidget(classSpec);
  }

  // Widget emission
  String _widgetToDartExpr(final WidgetNode node) {
    final Map<String, String> props = <String, String>{};
    node.properties.forEach((final key, final value) {
      props[key] = _exprToDart(value);
    });

    // Positional arguments (including cascade positional style)
    final List<String> posArgs = <String>[];
    for (final Expression a in node.positionalArgs) {
      posArgs.add(_exprToDart(a));
    }

    // Children sugar
    if (node.children.isNotEmpty) {
      // Multi-child widgets should always use children parameter
      final multiChildWidgets = <String>{
        'Column',
        'Row',
        'Stack',
        'ListView',
        'GridView',
        'GridView.builder',
      };

      if (multiChildWidgets.contains(node.name)) {
        final List<String> items = <String>[];
        for (final ASTNode c in node.children) {
          items.add(_widgetToDartExpr(c as WidgetNode));
        }
        props['children'] =
            '[\n${items.map((final e) => '        $e,').join('\n')}\n      ]';
      } else if (node.children.length == 1) {
        props['child'] = _widgetToDartExpr(node.children.first as WidgetNode);
      } else {
        final List<String> items = <String>[];
        for (final ASTNode c in node.children) {
          items.add(_widgetToDartExpr(c as WidgetNode));
        }
        props['children'] =
            '[\n${items.map((final e) => '        $e,').join('\n')}\n      ]';
      }
    }

    final String named = props.isEmpty
        ? ''
        : props.entries
              .map((final e) => '${e.key}: ${e.value}')
              .join(',\n      ');

    final String positional = posArgs.isEmpty
        ? ''
        : posArgs.map((final e) => e).join(', ');

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
  String _exprToDart(final Expression e) {
    if (e is StringExpression) return '"${_escapeString(e.value)}"';
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
    if (e is RawExpression) return e.text;
    return '';
  }

  String _escapeString(final String input) =>
      input.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
}
