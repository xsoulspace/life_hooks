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

      // Write widget name
      buffer.write('$_indentation${s.name}');

      // Handle positional arguments for constructor calls
      if (s.positionalArgs.isNotEmpty) {
        final args = s.positionalArgs.map((a) => a.accept(this)).join(', ');
        buffer.write('($args)');
      }
      buffer.writeln();

      // Handle properties and children
      if (s.properties.isNotEmpty ||
          s.children.isNotEmpty ||
          s.positionalCascadeArgs.isNotEmpty) {
        return _withIndent(1, () {
          // Properties with cascade notation
          for (final entry in s.properties.entries) {
            buffer.writeln(
              '$_indentation..${entry.key}: ${entry.value.accept(this)}',
            );
            if (config.spaceBetweenProperties) buffer.writeln();
          }

          // Cascade arguments (like in Text('value'))
          for (final arg in s.positionalCascadeArgs) {
            buffer.writeln('$_indentation..${arg.accept(this)}');
          }

          // Children handling
          if (s.children.isNotEmpty) {
            if (s.isSingleChild) {
              // buffer.writeln(
              //     '$_indentation..child: ${s.children.first.accept(this)}');
              buffer.writeln('$_indentation${s.children.first.accept(this)}');
            } else {
              for (final child in s.children) {
                buffer.write(child.accept(this));
              }
            }
          }

          return buffer.toString().trimRight();
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
