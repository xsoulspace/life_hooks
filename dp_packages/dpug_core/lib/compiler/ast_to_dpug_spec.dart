import 'package:dpug_code_builder/dpug_code_builder.dart' as dp;
import 'package:source_span/source_span.dart';

import 'ast_builder.dart';

/// Transforms our handwritten DPug AST into DPug IR specs.
///
/// Only minimal subset is supported per tests/README.
class AstToDpugSpec {
  final SourceFile file;
  AstToDpugSpec(this.file);

  /// Entry point: transform any top-level AST node into a `DpugSpec`.
  dp.DpugSpec transform(ASTNode node) {
    if (node is ClassNode) return _classToSpec(node);
    if (node is WidgetNode) {
      final dp.DpugWidgetBuilder wb = _widgetToBuilder(node);
      return wb.build();
    }
    throw StateError('Unsupported AST node: ${node.runtimeType}');
  }

  dp.DpugClassSpec _classToSpec(ClassNode node) {
    final dp.DpugClassBuilder builder = dp.Dpug.classBuilder()..name(node.name);
    for (final String a in node.annotations) {
      switch (a) {
        case 'stateful':
          builder.annotation(const dp.DpugAnnotationSpec(name: 'stateful'));
          break;
        case 'stateless':
          builder.annotation(const dp.DpugAnnotationSpec(name: 'stateless'));
          break;
        default:
          // ignore unknown annotations for now
          break;
      }
    }

    for (final StateVariable f in node.stateVariables) {
      final dp.DpugExpressionSpec? init = f.initializer != null
          ? _exprToSpec(f.initializer!)
          : null;
      if (f.annotation == 'listen' || f.annotation == 'state') {
        builder.listenField(name: f.name, type: f.type, initializer: init);
      }
    }

    for (final MethodNode m in node.methods) {
      if (m.name == 'build' && m.body is WidgetNode) {
        final dp.DpugWidgetBuilder wb = _widgetToBuilder(m.body as WidgetNode);
        builder.buildMethod(body: wb);
      }
    }

    return builder.build();
  }

  dp.DpugWidgetBuilder _widgetToBuilder(WidgetNode node) {
    final dp.DpugWidgetBuilder b = dp.DpugWidgetBuilder()..name(node.name);
    // Properties
    node.properties.forEach((String key, Expression value) {
      b.property(key, _exprToSpec(value));
    });

    // Positional/cascade arguments
    for (final Expression e in node.positionalArgs) {
      // Prefer cascade style in DPug output per README examples
      b.positionalCascadeArgument(_exprToSpec(e));
    }

    // Children
    for (final ASTNode child in node.children) {
      if (child is WidgetNode) {
        b.child(_widgetToBuilder(child));
      }
    }
    return b;
  }

  dp.DpugExpressionSpec _exprToSpec(Expression expr) {
    if (expr is StringExpression) {
      return dp.DpugExpressionSpec.string(expr.value);
    }
    if (expr is NumberExpression) {
      return dp.DpugExpressionSpec.numLiteral(expr.value);
    }
    if (expr is BooleanExpression) {
      return dp.DpugExpressionSpec.boolLiteral(expr.value);
    }
    if (expr is IdentifierExpression) {
      return dp.DpugExpressionSpec.reference(expr.name);
    }
    if (expr is AssignmentExpression) {
      return dp.DpugExpressionSpec.assignment(
        expr.target,
        _exprToSpec(expr.value),
      );
    }
    if (expr is ClosureExpression) {
      return dp.DpugExpressionSpec.closure(expr.params, _exprToSpec(expr.body));
    }
    throw StateError('Unsupported expression: ${expr.runtimeType}');
  }
}
