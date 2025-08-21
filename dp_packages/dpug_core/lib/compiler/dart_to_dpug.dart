import 'package:analyzer/dart/analysis/utilities.dart' as az;
import 'package:analyzer/dart/ast/ast.dart' as ast;
import 'package:source_span/source_span.dart';

/// Converts a subset of Dart (StatefulWidget) into DPug text directly.
class DartToDpug {
  DartToDpug(this.file);
  final SourceFile file;

  String convert(final String source) {
    final result = az.parseString(content: source);
    final ast.CompilationUnit unit = result.unit;
    for (final ast.CompilationUnitMember m in unit.declarations) {
      if (m is ast.ClassDeclaration) {
        final String? dpug = _classToDpug(unit, m);
        if (dpug != null) return dpug;
      }
    }
    throw StateError('No supported class found');
  }

  String? _classToDpug(
    final ast.CompilationUnit unit,
    final ast.ClassDeclaration c,
  ) {
    final String extendsStr = c.extendsClause?.superclass.toSource() ?? '';
    final bool isStateful = extendsStr.contains('StatefulWidget');
    if (!isStateful) return null;
    final String name = c.name.lexeme;
    final StringBuffer out = StringBuffer();
    out.writeln('@stateful');
    out.writeln('class $name');

    // Emit fields as @listen declarations (initializer defaulted)
    for (final ast.ClassMember m in c.members) {
      if (m is ast.FieldDeclaration) {
        final String typeStr = m.fields.type?.toSource() ?? 'dynamic';
        for (final ast.VariableDeclaration v in m.fields.variables) {
          final String def = _defaultForType(typeStr);
          out.writeln('  @listen $typeStr ${v.name.lexeme} = $def');
        }
      }
    }

    // Build method
    final ast.ClassDeclaration? stateClass = _findStateClass(unit, name);
    if (stateClass != null) {
      ast.MethodDeclaration? build;
      for (final ast.ClassMember mem in stateClass.members) {
        if (mem is ast.MethodDeclaration && mem.name.lexeme == 'build') {
          build = mem;
          break;
        }
      }
      if (build != null) {
        out.writeln();
        out.writeln('  Widget get build =>');
        final List<String> lines = _emitWidgetFromBuild(build, indent: 4);
        for (final String l in lines) out.writeln(l);
      }
    }
    return out.toString();
  }

  ast.ClassDeclaration? _findStateClass(
    final ast.CompilationUnit unit,
    final String widgetName,
  ) {
    for (final ast.CompilationUnitMember m in unit.declarations) {
      if (m is ast.ClassDeclaration) {
        if (m.name.lexeme == '_${widgetName}State') return m;
      }
    }
    return null;
  }

  List<String> _emitWidgetFromBuild(
    final ast.MethodDeclaration build, {
    required final int indent,
  }) {
    ast.Expression? expr;
    final ast.FunctionBody body = build.body;
    if (body is ast.ExpressionFunctionBody) {
      expr = body.expression;
    } else if (body is ast.BlockFunctionBody) {
      for (final ast.Statement s in body.block.statements) {
        if (s is ast.ReturnStatement) expr = s.expression;
      }
    }
    if (expr == null) throw StateError('Unsupported build body');
    return _emitWidget(expr, indent: indent);
  }

  List<String> _emitWidget(
    final ast.Expression expr, {
    required final int indent,
  }) {
    // Handle constructor calls like Column(...) which are MethodInvocation
    if (expr is ast.MethodInvocation) {
      final String name = expr.methodName.name;
      // Check if the original expression has 'const' keyword
      final String source = expr.toSource();
      final String constPrefix = source.startsWith('const ') ? 'const ' : '';

      final List<String> lines = <String>[];
      lines.add('${' ' * indent}$constPrefix$name');

      // Collect named and positional arguments
      final Map<String, ast.Expression> named = <String, ast.Expression>{};
      final List<ast.Expression> positional = <ast.Expression>[];

      for (final ast.Expression a in expr.argumentList.arguments) {
        if (a is ast.NamedExpression) {
          named[a.name.label.name] = a.expression;
        } else {
          positional.add(a);
        }
      }

      // Count non-children properties
      final int nonChildProperties = named.keys
          .where((final key) => key != 'child' && key != 'children')
          .length;

      if (named['child'] != null ||
          named['children'] != null ||
          nonChildProperties > 0 ||
          positional.isNotEmpty) {
        // Emit properties excluding child/children
        for (final MapEntry<String, ast.Expression> e in named.entries) {
          if (e.key == 'child' || e.key == 'children') continue;
          final ast.Expression value = e.value;

          if (value is ast.InstanceCreationExpression) {
            // Handle widget properties with proper indentation
            // Check if the original expression has 'const' keyword
            final String source = value.toSource();
            final String constPrefix = source.startsWith('const ')
                ? 'const '
                : '';

            lines.add(
              '${' ' * (indent + 2)}..${e.key}: $constPrefix${value.constructorName.type.toSource()}',
            );
            final Map<String, ast.Expression> widgetProps =
                <String, ast.Expression>{};
            for (final ast.Expression a in value.argumentList.arguments) {
              if (a is ast.NamedExpression) {
                widgetProps[a.name.label.name] = a.expression;
              }
            }
            for (final MapEntry<String, ast.Expression> prop
                in widgetProps.entries) {
              lines.add(
                '${' ' * (indent + 4)}..${prop.key}: ${_emitExpr(prop.value)}',
              );
            }
          } else {
            lines.add('${' ' * (indent + 2)}..${e.key}: ${_emitExpr(e.value)}');
          }
        }

        // Emit positional arguments as cascade style
        for (final ast.Expression posArg in positional) {
          lines.add('${' ' * (indent + 2)}..${_emitExpr(posArg)}');
        }

        // Emit children - handle both child and children properties
        final ast.Expression? child = named['child'];
        final ast.Expression? children = named['children'];
        if (child != null) {
          lines.addAll(_emitWidget(child, indent: indent + 2));
        } else if (children is ast.ListLiteral) {
          for (final ast.CollectionElement el in children.elements) {
            if (el is ast.Expression) {
              lines.addAll(_emitWidget(el, indent: indent + 2));
            }
          }
        }
      }
      return lines;
    }

    if (expr is ast.InstanceCreationExpression) {
      final String name = expr.constructorName.type.toSource();
      final List<String> lines = <String>[];
      lines.add('${' ' * indent}$name');

      // Collect named and positional arguments
      final Map<String, ast.Expression> named = <String, ast.Expression>{};
      final List<ast.Expression> positional = <ast.Expression>[];

      for (final ast.Expression a in expr.argumentList.arguments) {
        if (a is ast.NamedExpression) {
          named[a.name.label.name] = a.expression;
        } else {
          positional.add(a);
        }
      }

      // Handle special cases first
      final ast.Expression? child = named['child'];
      final ast.Expression? children = named['children'];

      // Count non-children properties
      final int nonChildProperties = named.keys
          .where((final key) => key != 'child' && key != 'children')
          .length;

      if (child != null ||
          children != null ||
          nonChildProperties > 0 ||
          positional.isNotEmpty) {
        // Emit properties excluding child/children
        for (final MapEntry<String, ast.Expression> e in named.entries) {
          if (e.key == 'child' || e.key == 'children') continue;
          final ast.Expression value = e.value;

          if (value is ast.InstanceCreationExpression) {
            // Handle widget properties with proper indentation
            // Check if the original expression has 'const' keyword
            final String source = value.toSource();
            final String constPrefix = source.startsWith('const ')
                ? 'const '
                : '';

            lines.add(
              '${' ' * (indent + 2)}..${e.key}: $constPrefix${value.constructorName.type.toSource()}',
            );
            final Map<String, ast.Expression> widgetProps =
                <String, ast.Expression>{};
            for (final ast.Expression a in value.argumentList.arguments) {
              if (a is ast.NamedExpression) {
                widgetProps[a.name.label.name] = a.expression;
              }
            }
            for (final MapEntry<String, ast.Expression> prop
                in widgetProps.entries) {
              lines.add(
                '${' ' * (indent + 4)}..${prop.key}: ${_emitExpr(prop.value)}',
              );
            }
          } else {
            lines.add('${' ' * (indent + 2)}..${e.key}: ${_emitExpr(e.value)}');
          }
        }

        // Emit positional arguments as cascade style
        for (final ast.Expression posArg in positional) {
          lines.add('${' ' * (indent + 2)}..${_emitExpr(posArg)}');
        }

        // Emit children - handle both child and children properties
        if (child != null) {
          lines.addAll(_emitWidget(child, indent: indent + 2));
        } else if (children is ast.ListLiteral) {
          for (final ast.CollectionElement el in children.elements) {
            if (el is ast.Expression) {
              lines.addAll(_emitWidget(el, indent: indent + 2));
            }
          }
        }
      }
      return lines;
    }
    // Fallback single-line expression
    return <String>['${' ' * indent}${expr.toSource()}'];
  }

  String _emitExpr(final ast.Expression e) {
    if (e is ast.SimpleStringLiteral) return "'${_escape(e.value)}'";
    if (e is ast.IntegerLiteral) return (e.value ?? 0).toString();
    if (e is ast.BooleanLiteral) return e.value ? 'true' : 'false';
    if (e is ast.ParenthesizedExpression) return '(${_emitExpr(e.expression)})';
    // Allow closures and invocations inline
    if (e is ast.FunctionExpression || e is ast.MethodInvocation) {
      return e.toSource();
    }
    if (e is ast.SimpleIdentifier) return e.name;
    if (e is ast.InstanceCreationExpression) {
      // Check if the original expression has 'const' keyword
      final String source = e.toSource();
      final String constPrefix = source.startsWith('const ') ? 'const ' : '';
      print(
        'DEBUG: InstanceCreationExpression source: "$source", constPrefix: "$constPrefix"',
      );

      // For widget expressions in properties, use cascade style
      final String name = e.constructorName.type.toSource();
      final Map<String, ast.Expression> named = <String, ast.Expression>{};
      final List<ast.Expression> positional = <ast.Expression>[];

      for (final ast.Expression a in e.argumentList.arguments) {
        if (a is ast.NamedExpression) {
          named[a.name.label.name] = a.expression;
        } else {
          positional.add(a);
        }
      }

      if (named.isEmpty && positional.isEmpty) {
        return '$constPrefix$name()';
      }

      final List<String> parts = <String>[name];
      // Add positional args
      for (final ast.Expression pos in positional) {
        parts.add(_emitExpr(pos));
      }
      // Add named args
      for (final MapEntry<String, ast.Expression> entry in named.entries) {
        parts.add('${entry.key}: ${_emitExpr(entry.value)}');
      }
      return '$constPrefix${parts.join(', ')}';
    }
    return e.toSource();
  }

  String _defaultForType(final String type) {
    final String t = type.trim();
    if (t.startsWith('List<')) return '[]';
    if (t == 'String') return "''";
    if (t == 'bool') return 'false';
    if (t.startsWith('int') || t.startsWith('double')) return '0';
    return 'null';
  }

  String _escape(final String s) =>
      s.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
}
