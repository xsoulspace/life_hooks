import '../formatters/dpug_config.dart';
import '../formatters/dpug_formatter.dart';
import '../specs/specs.dart';
import 'visitor.dart';

class DpugGeneratingVisitor implements DpugSpecVisitor<String> {
  final StringBuffer _buffer = StringBuffer();
  final DpugFormatter _formatter;
  int _indent = 0;

  DpugGeneratingVisitor([DpugConfig? config])
      : _formatter = DpugFormatter(config ?? const DpugConfig());

  @override
  String visitClass(DpugClassSpec spec) {
    final localBuffer = StringBuffer();
    _indent = 0;

    for (final annotation in spec.annotations) {
      localBuffer.writeln(annotation.accept(this));
    }
    localBuffer.writeln('class ${spec.name}');
    _indent++;

    for (final field in spec.stateFields) {
      localBuffer.writeln(
          '${_formatter.config.indent * _indent}${field.annotation.accept(this)}');
      localBuffer.writeln(
          '${_formatter.config.indent * _indent}${field.type} ${field.name}${_formatInitializer(field)}');
    }

    if (spec.methods.isNotEmpty) {
      localBuffer.writeln('');
      for (final method in spec.methods) {
        final methodCode = method.accept(this);
        localBuffer.write(methodCode);
      }
    }

    _indent--;
    return localBuffer.toString();
  }

  @override
  String visitMethod(DpugMethodSpec spec) {
    final localBuffer = StringBuffer();

    if (spec.name == 'build') {
      localBuffer.writeln('');
      localBuffer
          .writeln('${_formatter.config.indent * _indent}Widget get build =>');
      _indent++;
      final bodyCode = spec.body.accept(this);
      localBuffer.writeln('${_formatter.config.indent * _indent}$bodyCode');
      _indent--;
    } else if (spec.isGetter) {
      localBuffer.writeln(
          '${_formatter.config.indent * _indent}${spec.returnType} get ${spec.name} =>');
      _indent++;
      final bodyCode = spec.body.accept(this);
      localBuffer.writeln('${_formatter.config.indent * _indent}$bodyCode');
      _indent--;
    } else {
      final params = spec.parameters.map((p) => p.accept(this)).join(', ');
      localBuffer.writeln(
          '${_formatter.config.indent * _indent}${spec.returnType} ${spec.name}($params) =>');
      _indent++;
      final bodyCode = spec.body.accept(this);
      localBuffer.writeln('${_formatter.config.indent * _indent}$bodyCode');
      _indent--;
    }

    return localBuffer.toString();
  }

  @override
  String visitStateField(DpugStateFieldSpec spec) {
    final annotation = spec.annotation.accept(this);
    final init =
        spec.initializer != null ? ' = ${spec.initializer!.accept(this)}' : '';
    _writeLine('$annotation ${spec.type} ${spec.name}$init');
    return _buffer.toString();
  }

  @override
  String visitParameter(DpugParameterSpec spec) {
    final required = spec.isRequired ? 'required ' : '';
    final named = spec.isNamed ? '${spec.name}: ' : '';
    final defaultValue = spec.defaultValue != null
        ? ' = ${spec.defaultValue!.accept(this)}'
        : '';
    return '$required$named${spec.type} ${spec.name}$defaultValue';
  }

  @override
  String visitWidget(DpugWidgetSpec spec) {
    final localBuffer = StringBuffer();

    // Write widget name
    localBuffer.writeln('${_formatter.config.indent * _indent}${spec.name}');
    _indent++;

    // Handle positional cascade arguments
    for (final arg in spec.positionalCascadeArgs) {
      if (arg is DpugStringLiteralSpec) {
        localBuffer
            .writeln('${_formatter.config.indent * _indent}..\'${arg.value}\'');
      } else {
        localBuffer.writeln(
            '${_formatter.config.indent * _indent}..${arg.accept(this)}');
      }
    }

    // Handle all properties including 'child' if explicitly set
    for (final entry in spec.properties.entries) {
      localBuffer.writeln(
          '${_formatter.config.indent * _indent}..${entry.key}: ${entry.value.accept(this)}');
    }

    // Handle positional arguments
    if (spec.positionalArgs.isNotEmpty) {
      final args = spec.positionalArgs.map((a) => a.accept(this)).join(', ');
      localBuffer.write('(${args})');
      localBuffer.writeln();
    }

    // Handle automatic child/children syntax sugar
    if (spec.children.isNotEmpty &&
        !spec.properties.containsKey('child') &&
        !spec.properties.containsKey('children')) {
      for (final child in spec.children) {
        final childCode = child.accept(this);
        localBuffer.write(childCode);
      }
    }

    _indent--;
    return localBuffer.toString();
  }

  @override
  String visitAnnotation(DpugAnnotationSpec spec) {
    final args = spec.arguments.map((a) => a.accept(this)).join(', ');
    return '@${spec.name}${args.isEmpty ? '' : '($args)'}';
  }

  @override
  String visitReference(DpugReferenceSpec spec) {
    return spec.name;
  }

  @override
  String visitListLiteral(DpugListLiteralSpec spec) {
    final values = spec.values.map((v) => v.accept(this)).join(', ');
    return '[$values]';
  }

  @override
  String visitStringLiteral(DpugStringLiteralSpec spec) {
    return "'${spec.value}'";
  }

  @override
  String visitLambda(DpugLambdaSpec spec) {
    final params = spec.parameters.join(', ');
    return '($params) => ${spec.body.accept(this)}';
  }

  @override
  String visitAssignment(DpugAssignmentSpec spec) {
    return '${spec.target} = ${spec.value.accept(this)}';
  }

  void _writeAnnotations(Iterable<DpugAnnotationSpec> annotations) {
    for (final annotation in annotations) {
      _writeLine(annotation.accept(this));
    }
  }

  void _writeLine(String line) {
    if (line.isNotEmpty) {
      _buffer.writeln('${_formatter.config.indent * _indent}$line');
    } else {
      _buffer.writeln();
    }
  }

  String visitMultipleClasses(List<DpugClassSpec> specs) {
    final classes = specs.map((spec) => spec.accept(this)).toList();
    return _formatter.format(classes.join('\n\n'));
  }

  String _formatInitializer(DpugStateFieldSpec field) {
    return field.initializer != null
        ? ' = ${field.initializer!.accept(this)}'
        : '';
  }
}
