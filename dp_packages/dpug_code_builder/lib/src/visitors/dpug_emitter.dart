import '../formatters/dpug_config.dart';
import '../specs/specs.dart';
import 'base_visitor.dart';

class DpugEmitter extends BaseVisitor<String> {
  DpugEmitter([this.config = const DpugConfig()]);
  final DpugConfig config;
  int _indent = 0;

  String get _indentation => List.filled(_indent, config.indent).join();

  String _withIndent(final int amount, final String Function() block) {
    final previous = _indent;
    try {
      _indent += amount;
      return block();
    } finally {
      _indent = previous;
    }
  }

  @override
  String visitClass(final DpugClassSpec spec, [final String? context]) =>
      visitSafely(spec, (final s) {
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

            // Ensure single blank line after fields if there are methods
            if (s.stateFields.isNotEmpty &&
                s.methods.isNotEmpty &&
                config.spaceBetweenMembers) {
              bodyBuffer.writeln();
            }

            // Write methods
            if (s.methods.isNotEmpty) {
              // Note: blank line already added above if needed
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

  @override
  String visitMethod(final DpugMethodSpec spec, [final String? context]) =>
      visitSafely(spec, (final s) {
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
          final params = s.parameters
              .map((final p) => p.accept(this))
              .join(', ');
          buffer.write('$_indentation${s.returnType} ${s.name}($params) =>');
        }
        buffer.writeln();

        return _withIndent(1, () {
          buffer.write(s.body.accept(this));
          return buffer.toString();
        });
      });

  String visitClasses(final Iterable<DpugClassSpec> specs) =>
      specs.map((final s) => s.accept(this).trimRight()).join('\n\n');

  @override
  String visitWidget(
    final DpugWidgetSpec spec, [
    final String? context,
  ]) => visitSafely(spec, (final s) {
    final buffer = StringBuffer();

    // Write widget name with inline positional args if present
    if (s.positionalArgs.isNotEmpty) {
      final args = s.positionalArgs.map((final a) => a.accept(this)).join(', ');
      buffer.write('$_indentation${s.name}($args)');
    } else {
      buffer.write('$_indentation${s.name}');
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
          final raw = entry.value.accept(this);
          final valueStr = raw.trimRight();
          if (valueStr.contains('\n')) {
            final lines = valueStr.split('\n');
            // Trim excessive leading spaces relative to the smallest indent among non-empty lines
            int minIndent = 1 << 30;
            for (var i = 1; i < lines.length; i++) {
              final l = lines[i];
              if (l.trim().isEmpty) continue;
              final count = l.length - l.trimLeft().length;
              if (count < minIndent) minIndent = count;
            }
            if (minIndent == (1 << 30)) minIndent = 0;

            String normalize(final String line) {
              if (line.trim().isEmpty) return '';
              final trimmed = line.length >= minIndent
                  ? line.substring(minIndent)
                  : line.trimLeft();
              return trimmed;
            }

            // First line stays inline after ':'; only trim existing leading spaces
            final firstInline = lines.first.trimLeft();
            buffer.writeln('$_indentation..${entry.key}: $firstInline');
            // Subsequent lines get aligned to the current indentation
            for (var i = 1; i < lines.length; i++) {
              final ln = normalize(lines[i]);
              if (ln.isEmpty) {
                buffer.writeln();
              } else {
                buffer.writeln('$_indentation${config.indent}$ln');
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
            buffer.write(allChildren.first.accept(this).trimRight());
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

  @override
  String visitBinary(final DpugBinarySpec spec, [final String? context]) =>
      '${spec.left.accept(this)} ${spec.operator} ${spec.right.accept(this)}';

  @override
  String visitInvoke(final DpugInvokeSpec spec, [final String? context]) {
    final args = spec.positionedArguments
        .map((final a) => a.accept(this))
        .toList();
    final namedArgs = spec.namedArguments.entries
        .map((final e) => '${e.key}: ${e.value.accept(this)}')
        .toList();
    final allArgs = [...args, ...namedArgs].join(', ');
    final target = spec.target.accept(this);
    return '$target($allArgs)';
  }

  @override
  String visitLiteral(final DpugLiteralSpec spec, [final String? context]) =>
      spec.value.toString();

  @override
  String visitListLiteral(
    final DpugListLiteralSpec spec, [
    final String? context,
  ]) {
    final values = spec.values.map((final v) => v.accept(this)).join(', ');
    return '[$values]';
  }

  @override
  String visitStringLiteral(
    final DpugStringLiteralSpec spec, [
    final String? context,
  ]) {
    final escaped = spec.value
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll('\n', r'\n');
    return "'$escaped'";
  }

  @override
  String visitClosureExpression(
    final DpugClosureExpressionSpec spec, [
    final String? context,
  ]) {
    final params = spec.method.parameters.map((final p) => p.name).join(', ');
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
  String visitReference(
    final DpugReferenceSpec spec, [
    final String? context,
  ]) => spec.url ?? spec.symbol;

  @override
  String visitParameter(final DpugParameterSpec spec, [final String? context]) {
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
  String visitStateField(
    final DpugStateFieldSpec spec, [
    final String? context,
  ]) {
    final annotation = spec.annotation.accept(this);
    final initializer = spec.initializer != null
        ? ' = ${spec.initializer!.accept(this)}'
        : '';
    return '$annotation ${spec.type} ${spec.name}$initializer';
  }

  @override
  String visitAnnotation(
    final DpugAnnotationSpec spec, [
    final String? context,
  ]) {
    if (spec.name == 'state') {
      return '@listen'; // Convert @state to @listen per README syntax
    }
    final args = spec.arguments.map((final a) => a.accept(this)).join(', ');
    return '@${spec.name}${args.isEmpty ? '' : '($args)'}';
  }

  @override
  String visitAssignment(
    final DpugAssignmentSpec spec, [
    final String? context,
  ]) => '${spec.target} = ${spec.value.accept(this)}';

  @override
  String visitConstructor(
    final DpugConstructorSpec spec, [
    final String? context,
  ]) {
    final params = spec.optionalParameters
        .map((final p) => p.accept(this))
        .join(', ');
    return '$_indentation${spec.name}($params)';
  }

  @override
  String visitReferenceExpression(
    final DpugReferenceExpressionSpec spec, [
    final String? context,
  ]) => spec.name;

  @override
  String visitCode(final DpugCodeSpec spec, [final String? context]) =>
      spec.value;

  @override
  String visitExpression(
    final DpugExpressionSpec spec, [
    final String? context,
  ]) {
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
  String visitBoolLiteral(
    final DpugBoolLiteralSpec spec, [
    final String? context,
  ]) => spec.value.toString();

  @override
  String visitNumLiteral(
    final DpugNumLiteralSpec spec, [
    final String? context,
  ]) => spec.value.toString();
}
