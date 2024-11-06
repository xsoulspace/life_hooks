import '../formatters/dpug_config.dart';
import '../specs/specs.dart';
import 'base_visitor.dart';

class DpugEmitter extends BaseVisitor<String> {
  final DpugConfig config;
  int _indent = 0;

  DpugEmitter([this.config = const DpugConfig()]);

  String get _indentation => config.indent * _indent;

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
      buffer.write(_withIndent(1, () {
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
      }));

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

      // Handle constructor call style (e.g., GridView.builder)
      if (s.name.contains('.')) {
        if (s.positionalArgs.isNotEmpty) {
          final args = s.positionalArgs.map((a) => a.accept(this)).join(', ');
          buffer.write('($args)');
        }
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
                '$_indentation..${entry.key}: ${entry.value.accept(this)}');
            if (config.spaceBetweenProperties) buffer.writeln();
          }

          // Cascade arguments (like in Text('value'))
          for (final arg in s.positionalCascadeArgs) {
            buffer.writeln('$_indentation..${arg.accept(this)}');
          }

          // Children handling
          if (s.children.isNotEmpty) {
            if (s.isSingleChild) {
              buffer.writeln(
                  '$_indentation..child: ${s.children.first.accept(this)}');
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

  // void _writeProperty(StringBuffer buffer, String key, DpugSpec value) {
  //   if (value is DpugWidgetSpec) {
  //     buffer.writeln('$_indentation..${key}:');
  //     buffer.write(_withIndent(1, () => value.accept(this)));
  //   } else if (value is DpugLambdaSpec) {
  //     buffer.writeln('$_indentation..${key}: ${value.accept(this)}');
  //   } else if (value is DpugReferenceSpec && _isComplexExpression(value.name)) {
  //     buffer.write('$_indentation..${key}: ');
  //     buffer.writeln(value.name);
  //   } else {
  //     buffer.writeln('$_indentation..${key}: ${value.accept(this)}');
  //   }
  // }

  // bool _isComplexExpression(String code) {
  //   return code.contains('{') || code.contains('=>') || code.contains('\n');
  // }

  @override
  String visitBinary(DpugBinarySpec spec, [String? context]) {
    return '${spec.left.accept(this)} ${spec.operator} ${spec.right.accept(this)}';
  }

  @override
  String visitInvoke(DpugInvokeSpec spec, [String? context]) {
    final args = spec.positionedArguments.map((a) => a.accept(this));
    final namedArgs = spec.positionedArguments.entries
        .map((e) => '${e.key}: ${e.value.accept(this)}');

    final allArgs = [...args, ...namedArgs].join(', ');
    return '${spec.target}($allArgs)';
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
  String visitClosureExpression(DpugClosureExpressionSpec spec,
      [String? context]) {
    final params = spec.parameters.join(', ');
    final body = spec.body.accept(this);
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
    return '$required$named${spec.type} ${spec.name}$defaultValue';
  }

  @override
  String visitStateField(DpugStateFieldSpec spec, [String? context]) {
    final annotation = spec.annotation.accept(this);
    final initializer =
        spec.initializer != null ? ' = ${spec.initializer!.accept(this)}' : '';
    return '$annotation ${spec.type} ${spec.name}$initializer';
  }

  @override
  String visitAnnotation(DpugAnnotationSpec spec) {
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
    final params = spec.parameters.map((p) => p.accept(this)).join(', ');
    return '$_indentation${spec.name}($params)';
  }

  @override
  String visitReferenceExpression(DpugReferenceExpressionSpec spec,
      [String? context]) {
    return spec.accept(this);
  }
}
