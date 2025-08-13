import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart' as az;
import 'package:analyzer/dart/ast/ast.dart' as ast;
import 'package:dpug_code_builder/dpug_code_builder.dart' as dp;
import 'package:source_span/source_span.dart';

/// Minimal analyzer -> DPug IR transformer supporting a subset needed by tests.
class DartAstToDpugSpec {
  final SourceFile file;
  DartAstToDpugSpec(this.file);

  /// Parse source and transform the first supported class to a `DpugSpec`.
  dp.DpugSpec transformFromSource(String source) {
    final ParseStringResult result = az.parseString(content: source);
    final ast.CompilationUnit unit = result.unit;

    for (final ast.CompilationUnitMember member in unit.declarations) {
      if (member is ast.ClassDeclaration) {
        final dp.DpugClassSpec? s = _classToSpec(member);
        if (s != null) return s;
      }
    }
    throw StateError('No supported class found');
  }

  dp.DpugClassSpec? _classToSpec(ast.ClassDeclaration c) {
    // Look for StatefulWidget pattern and its State class
    final bool isStateful =
        c.extendsClause?.superclass.name2.lexeme == 'StatefulWidget';
    if (!isStateful) return null;

    final String name = c.name.lexeme;
    final dp.DpugClassBuilder builder = dp.Dpug.classBuilder()
      ..name(name)
      ..annotation(const dp.DpugAnnotationSpec(name: 'stateful'));

    // Collect final fields (constructor params) as listen fields
    for (final ast.ClassMember m in c.members) {
      if (m is ast.FieldDeclaration) {
        for (final ast.VariableDeclaration v in m.fields.variables) {
          final String fieldName = v.name.lexeme;
          final String typeStr = m.fields.type?.toSource() ?? 'dynamic';
          final dp.DpugExpressionSpec? initializer = v.initializer != null
              ? _anyExprToDpug(v.initializer!)
              : null;
          builder.listenField(
            name: fieldName,
            type: typeStr,
            initializer: initializer,
          );
        }
      }
    }

    // Locate the State class with build method
    final ast.ClassDeclaration? stateClass = _findStateClass(
      unit: c.parent as ast.CompilationUnit,
      widgetName: name,
    );
    if (stateClass != null) {
      final buildMethods = stateClass.members
          .whereType<ast.MethodDeclaration>()
          .where((m) => m.name.lexeme == 'build');
      if (buildMethods.isNotEmpty) {
        final ast.MethodDeclaration build = buildMethods.first;
        final dp.DpugWidgetBuilder wb = _extractBuildBody(build);
        builder.buildMethod(body: wb);
      }
    }

    return builder.build();
  }

  ast.ClassDeclaration? _findStateClass({
    required ast.CompilationUnit unit,
    required String widgetName,
  }) {
    for (final ast.CompilationUnitMember m in unit.declarations) {
      if (m is ast.ClassDeclaration) {
        final String n = m.name.lexeme;
        if (n == '_${widgetName}State') return m;
      }
    }
    return null;
  }

  dp.DpugWidgetBuilder _extractBuildBody(ast.MethodDeclaration build) {
    // Expect a return statement with a constructor invocation.
    final ast.FunctionBody body = build.body;
    ast.Expression? expr;
    if (body is ast.ExpressionFunctionBody) {
      expr = body.expression;
    } else if (body is ast.BlockFunctionBody) {
      for (final ast.Statement s in body.block.statements) {
        if (s is ast.ReturnStatement) expr = s.expression;
      }
    }
    if (expr == null) throw StateError('Unsupported build body');
    return _exprToWidget(expr);
  }

  dp.DpugWidgetBuilder _exprToWidget(ast.Expression expr) {
    if (expr is ast.InstanceCreationExpression) {
      final String name = expr.constructorName.type.name2.lexeme;
      final dp.DpugWidgetBuilder b = dp.DpugWidgetBuilder()..name(name);
      // Positional args
      for (final ast.Expression _
          in expr.argumentList.arguments.whereType<ast.SimpleIdentifier>()) {
        // Not typically used; skip
      }
      // Named args and common patterns
      for (final ast.Expression e in expr.argumentList.arguments) {
        if (e is ast.NamedExpression) {
          final String key = e.name.label.name;
          if ((key == 'child' || key == 'children')) {
            final ast.Expression childExpr = e.expression;
            if (childExpr is ast.InstanceCreationExpression) {
              b.child(_exprToWidget(childExpr));
            } else if (childExpr is ast.ListLiteral) {
              for (final ast.CollectionElement item in childExpr.elements) {
                b.child(_exprToWidget(item as ast.Expression));
              }
            }
          } else {
            final dp.DpugExpressionSpec value = _anyExprToDpug(e.expression);
            b.property(key, value);
          }
        }
      }
      // children/child may contain nested constructors
      return b;
    }
    throw StateError('Unsupported widget expression: ${expr.runtimeType}');
  }

  dp.DpugExpressionSpec _anyExprToDpug(ast.Expression e) {
    if (e is ast.SimpleStringLiteral) {
      return dp.DpugExpressionSpec.string(e.value);
    }
    if (e is ast.IntegerLiteral) {
      return dp.DpugExpressionSpec.numLiteral(e.value ?? 0);
    }
    if (e is ast.BooleanLiteral) {
      return dp.DpugExpressionSpec.boolLiteral(e.value);
    }
    if (e is ast.SimpleIdentifier) {
      return dp.DpugExpressionSpec.reference(e.name);
    }
    if (e is ast.MethodInvocation) {
      // Render invocation as reference text for now
      return dp.DpugExpressionSpec.reference(e.toSource());
    }
    if (e is ast.FunctionExpression) {
      final body = e.body;
      if (body is ast.ExpressionFunctionBody) {
        final String bodyStr = body.expression.toSource();
        return dp.DpugExpressionSpec.closure(
          <String>[],
          dp.DpugExpressionSpec.reference(bodyStr),
        );
      }
      return dp.DpugExpressionSpec.reference(e.toSource());
    }
    if (e is ast.InstanceCreationExpression) {
      final dp.DpugWidgetBuilder w = _exprToWidget(e);
      return dp.DpugExpressionSpec.widget(w);
    }
    // Fallback to raw source
    return dp.DpugExpressionSpec.reference(e.toSource());
  }
}
