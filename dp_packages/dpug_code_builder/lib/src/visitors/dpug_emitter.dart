import '../formatters/dpug_config.dart';
import '../specs/specs.dart';
import 'base_visitor.dart';

class DpugEmitter extends BaseVisitor<String> {
  final DpugConfig config;
  int _indent = 0;

  DpugEmitter([this.config = const DpugConfig()]);

  String get _indentation => List.filled(_indent, config.indent).join();

  String _withIndent(int amount, String Function() block) {
    final previous = _indent;
    try {
      _indent += amount;
      return block();
    } finally {
      _indent = previous;
    }
  }

  @override
  String visitClass(DpugClassSpec spec, [String? context]) {
    return visitSafely(spec, (s) {
      final buffer = StringBuffer();

      // Write annotations
      for (final annotation in s.annotations) {
        buffer.writeln(annotation.accept(this));
        if (config.spaceAfterAnnotations) buffer.writeln();
      }

      // Write class declaration
      buffer.writeln('class ${s.name}');

      // Write class body
      buffer.write(
        _withIndent(1, () {
          final bodyBuffer = StringBuffer();

          // Write fields
          var first = true;
          for (final field in s.stateFields) {
            if (!first && config.spaceBetweenMembers) bodyBuffer.writeln();
            first = false;

            final fieldStr = field.accept(this);
            bodyBuffer.writeln('$_indentation$fieldStr');
          }

          // Write methods
          if (s.methods.isNotEmpty) {
            if (s.stateFields.isNotEmpty && config.spaceBetweenMembers) {
              bodyBuffer.writeln();
            }

            first = true;
            for (final method in s.methods) {
              if (!first && config.spaceBetweenMembers) bodyBuffer.writeln();
              first = false;

              bodyBuffer.write(method.accept(this));
              bodyBuffer.writeln();
            }
          }

          return bodyBuffer.toString();
        }),
      );

      return buffer.toString();
    });
  }

  @override
  String visitMethod(DpugMethodSpec spec, [String? context]) {
    return visitSafely(spec, (s) {
      final buffer = StringBuffer();

      // Handle build method specially
      if (s.name == 'build') {
        buffer.write('$_indentation${s.returnType} get build =>');
        buffer.writeln();
        return _withIndent(1, () {
          buffer.write(s.body.accept(this));
          return buffer.toString();
        });
      }

      // Handle other methods
      if (s.isGetter) {
        buffer.write('$_indentation${s.returnType} get ${s.name} =>');
      } else {
        final params = s.parameters.map((p) => p.accept(this)).join(', ');
        buffer.write('$_indentation${s.returnType} ${s.name}($params) =>');
      }
      buffer.writeln();

      return _withIndent(1, () {
        buffer.write(s.body.accept(this));
        return buffer.toString();
      });
    });
  }

  String visitClasses(Iterable<DpugClassSpec> specs) =>
      specs.map((s) => s.accept(this)).join('\n\n');

  @override
  String visitWidget(DpugWidgetSpec spec, [String? context]) {
    return visitSafely(spec, (s) {
      final buffer = StringBuffer();

      // Write widget name with inline positional args if present
      if (s.positionalArgs.isNotEmpty) {
        final args = s.positionalArgs.map((a) => a.accept(this)).join(', ');
        buffer.writeln('$_indentation${s.name}($args)');
      } else {
        buffer.writeln('$_indentation${s.name}');
      }

      // Handle properties and children
      if (s.properties.isNotEmpty ||
          s.children.isNotEmpty ||
          s.positionalCascadeArgs.isNotEmpty) {
        return _withIndent(1, () {
          // Convert `child:` widget property into sugar children for emission
          final syntheticChildren = <DpugWidgetSpec>[];
          final filteredEntries = <MapEntry<String, DpugExpressionSpec>>[];
          for (final entry in s.properties.entries) {
            if (entry.key == 'child' &&
                s.children.isEmpty &&
                entry.value is DpugWidgetExpressionSpec) {
              final widgetExpr = entry.value as DpugWidgetExpressionSpec;
              syntheticChildren.add(widgetExpr.builder.build());
              continue; // skip emitting ..child:
            }
            filteredEntries.add(entry);
          }

          // Properties with cascade notation. If the value spans multiple
          // lines, align the first token after ':' and preserve child block
          // indentation relative to the current widget level.
          for (final entry in filteredEntries) {
            final valueStr = entry.value.accept(this);
            if (valueStr.contains('\n')) {
              final lines = valueStr.split('\n');
              String stripPrefix(String line) => line.startsWith(_indentation)
                  ? line.substring(_indentation.length)
                  : line;
              buffer.writeln(
                '$_indentation..${entry.key}: ${stripPrefix(lines.first)}',
              );
              for (var i = 1; i < lines.length; i++) {
                final line = stripPrefix(lines[i]);
                if (line.trim().isEmpty) {
                  buffer.writeln();
                } else {
                  buffer.writeln('$_indentation$line');
                }
              }
            } else {
              buffer.writeln('$_indentation..${entry.key}: $valueStr');
            }
            if (config.spaceBetweenProperties) buffer.writeln();
          }

          // Cascade arguments (like in Text('value'))
          for (final arg in s.positionalCascadeArgs) {
            buffer.writeln('$_indentation..${arg.accept(this)}');
          }

          // Children handling (including synthetic ones from `child:`)
          final allChildren = [...s.children, ...syntheticChildren];
          if (allChildren.isNotEmpty) {
            if (allChildren.length == 1) {
              buffer.write(allChildren.first.accept(this));
            } else {
              for (final child in allChildren) {
                buffer.write(child.accept(this));
              }
            }
          }

          return buffer.toString();
        });
      }

      return buffer.toString();
    });
  }

  @override
  String visitBinary(DpugBinarySpec spec, [String? context]) {
    return '${spec.left.accept(this)} ${spec.operator} ${spec.right.accept(this)}';
  }

  @override
  String visitInvoke(DpugInvokeSpec spec, [String? context]) {
    final args = spec.positionedArguments.map((a) => a.accept(this)).toList();
    final namedArgs = spec.namedArguments.entries
        .map((e) => '${e.key}: ${e.value.accept(this)}')
        .toList();
    final allArgs = [...args, ...namedArgs].join(', ');
    final target = spec.target.accept(this);
    return '$target($allArgs)';
  }

  @override
  String visitLiteral(DpugLiteralSpec spec, [String? context]) {
    return spec.value.toString();
  }

  @override
  String visitListLiteral(DpugListLiteralSpec spec, [String? context]) {
    final values = spec.values.map((v) => v.accept(this)).join(', ');
    return '[$values]';
  }

  @override
  String visitStringLiteral(DpugStringLiteralSpec spec, [String? context]) {
    final escaped = spec.value
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll('\n', '\\n');
    return "'$escaped'";
  }

  @override
  String visitClosureExpression(
    DpugClosureExpressionSpec spec, [
    String? context,
  ]) {
    final params = spec.method.parameters.map((p) => p.name).join(', ');
    final body = spec.method.body.accept(this);
    // If body contains newlines, preserve multiline block after the colon
    if (body.contains('\n')) {
      final lines = body.split('\n');
      final buf = StringBuffer('($params) {\n');
      for (final line in lines) {
        if (line.trim().isEmpty) {
          buf.writeln();
        } else {
          buf.writeln('${config.indent}$line');
        }
      }
      buf.write('}');
      return buf.toString();
    }
    return '($params) => $body';
  }

  @override
  String visitReference(DpugReferenceSpec spec, [String? context]) {
    return spec.url ?? spec.symbol;
  }

  @override
  String visitParameter(DpugParameterSpec spec, [String? context]) {
    final required = spec.isRequired ? 'required ' : '';
    final named = spec.isNamed ? '${spec.name}: ' : '';
    final defaultValue = spec.defaultValue != null
        ? ' = ${spec.defaultValue!.accept(this)}'
        : '';
    final type = spec.type != null ? spec.type!.accept(this) : '';
    final spacedType = type.isNotEmpty ? '$type ' : '';
    return '$required$named$spacedType${spec.name}$defaultValue';
  }

  @override
  String visitStateField(DpugStateFieldSpec spec, [String? context]) {
    final annotation = spec.annotation.accept(this);
    final initializer = spec.initializer != null
        ? ' = ${spec.initializer!.accept(this)}'
        : '';
    return '$annotation ${spec.type} ${spec.name}$initializer';
  }

  @override
  String visitAnnotation(DpugAnnotationSpec spec, [String? context]) {
    if (spec.name == 'state') {
      return '@listen'; // Convert @state to @listen per README syntax
    }
    final args = spec.arguments.map((a) => a.accept(this)).join(', ');
    return '@${spec.name}${args.isEmpty ? '' : '($args)'}';
  }

  @override
  String visitAssignment(DpugAssignmentSpec spec, [String? context]) {
    return '${spec.target} = ${spec.value.accept(this)}';
  }

  @override
  String visitConstructor(DpugConstructorSpec spec, [String? context]) {
    final params = spec.optionalParameters
        .map((p) => p.accept(this))
        .join(', ');
    return '$_indentation${spec.name}($params)';
  }

  @override
  String visitReferenceExpression(
    DpugReferenceExpressionSpec spec, [
    String? context,
  ]) {
    return spec.name;
  }

  @override
  String visitCode(DpugCodeSpec spec, [String? context]) {
    return spec.value;
  }

  @override
  String visitExpression(DpugExpressionSpec spec, [String? context]) {
    if (spec is DpugReferenceExpressionSpec) {
      return visitReferenceExpression(spec);
    } else if (spec is DpugStringLiteralSpec) {
      return visitStringLiteral(spec);
    } else if (spec is DpugWidgetExpressionSpec) {
      return spec.builder.accept(this);
    } else if (spec is DpugInvokeSpec) {
      return visitInvoke(spec);
    } else if (spec is DpugBoolLiteralSpec) {
      return visitBoolLiteral(spec);
    } else if (spec is DpugNumLiteralSpec) {
      return visitNumLiteral(spec);
    } else if (spec is DpugAssignmentSpec) {
      return visitAssignment(spec);
    } else if (spec is DpugBinarySpec) {
      return visitBinary(spec);
    } else if (spec is DpugClosureExpressionSpec) {
      return visitClosureExpression(spec);
    } else if (spec is DpugLiteralSpec) {
      return visitLiteral(spec);
    } else if (spec is DpugListLiteralSpec) {
      return visitListLiteral(spec);
    }
    return spec.toString();
  }

  @override
  String visitBoolLiteral(DpugBoolLiteralSpec spec, [String? context]) {
    return spec.value.toString();
  }

  @override
  String visitNumLiteral(DpugNumLiteralSpec spec, [String? context]) {
    return spec.value.toString();
  }
}
