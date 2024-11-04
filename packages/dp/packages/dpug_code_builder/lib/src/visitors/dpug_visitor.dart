import '../specs/specs.dart';
import 'visitor.dart';

class DpugGeneratingVisitor implements DpugSpecVisitor<String> {
  final StringBuffer _buffer = StringBuffer();
  int _indent = 0;

  @override
  String visitClass(DpugClassSpec spec) {
    _writeAnnotations(spec.annotations);
    _writeLine('class ${spec.name}');
    _indent++;

    for (final field in spec.stateFields) {
      field.accept(this);
    }

    for (final method in spec.methods) {
      method.accept(this);
      _writeLine('');
    }

    _indent--;
    return _buffer.toString();
  }

  @override
  String visitStateField(DpugStateFieldSpec spec) {
    _writeAnnotations([spec.annotation]);
    final init =
        spec.initializer != null ? ' = ${spec.initializer!.accept(this)}' : '';
    _writeLine('${spec.type} ${spec.name}$init');
    return _buffer.toString();
  }

  @override
  String visitMethod(DpugMethodSpec spec) {
    if (spec.isGetter) {
      _writeLine('${spec.returnType} get ${spec.name} =>');
      _indent++;
      _writeLine(spec.body.accept(this));
      _indent--;
      return _buffer.toString();
    }

    final params = spec.parameters.map((p) => p.accept(this)).join(', ');
    _writeLine('${spec.returnType} ${spec.name}($params) {');
    _indent++;
    _writeLine(spec.body.accept(this));
    _indent--;
    _writeLine('}');
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
    _writeLine(spec.name);
    _indent++;

    // Handle positional cascade arguments
    for (final arg in spec.positionalCascadeArgs) {
      if (arg is DpugStringLiteralSpec) {
        _writeLine('..\'${arg.value}\'');
      } else {
        _writeLine('..${arg.accept(this)}');
      }
    }

    // Handle regular positional arguments
    if (spec.positionalArgs.isNotEmpty) {
      final args = spec.positionalArgs.map((a) => a.accept(this)).join(', ');
      _buffer.write('(${args})');
      _buffer.writeln();
    }

    // Handle properties
    for (final entry in spec.properties.entries) {
      _writeLine('..${entry.key}: ${entry.value.accept(this)}');
    }

    // Handle children
    for (final child in spec.children) {
      child.accept(this);
    }

    _indent--;
    return _buffer.toString();
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
      _buffer.writeln('${'  ' * _indent}$line');
    } else {
      _buffer.writeln();
    }
  }
}
