import '../specs/specs.dart';
import 'visitor.dart';

class DpugEmitter implements DpugSpecVisitor<String> {
  final DpugConfig config;
  final StringBuffer _buffer = StringBuffer();
  int _indent = 0;

  DpugEmitter([this.config = const DpugConfig()]);

  String get _indentation => config.indent * _indent;

  @override
  String visitClass(DpugClassSpec spec) {
    _indent = 0;
    _buffer.clear();

    // Write class declaration and annotations
    for (final annotation in spec.annotations) {
      _buffer.writeln(annotation.accept(this));
    }
    _buffer.writeln('class ${spec.name}');
    _indent++;

    // Write state fields with inline annotations
    for (final field in spec.stateFields) {
      final annotation = field.annotation.accept(this);
      final initializer = _formatInitializer(field);
      _buffer.writeln(
          '$_indentation$annotation ${field.type} ${field.name}$initializer');
    }

    // Write methods
    if (spec.methods.isNotEmpty) {
      _buffer.writeln(''); // Single newline before methods
      for (final method in spec.methods) {
        _buffer.write(method.accept(this));
      }
    }

    _indent--;
    return _buffer.toString();
  }

  @override
  String visitMethod(DpugMethodSpec spec) {
    _buffer.clear();

    if (spec.name == 'build') {
      _buffer.writeln('${_indentation}Widget get build =>');
      _indent++;
      _buffer.write(spec.body.accept(this));
      _indent--;
    } else if (spec.isGetter) {
      _buffer.writeln('$_indentation${spec.returnType} get ${spec.name} =>');
      _indent++;
      _buffer.write(spec.body.accept(this));
      _indent--;
    } else {
      final params = spec.parameters.map((p) => p.accept(this)).join(', ');
      _buffer
          .writeln('$_indentation${spec.returnType} ${spec.name}($params) =>');
      _indent++;
      _buffer.write(spec.body.accept(this));
      _indent--;
    }

    return _buffer.toString();
  }

  @override
  String visitWidget(DpugWidgetSpec spec) {
    _buffer.clear();
    final currentIndent = _indent;

    // Write widget name with optional positional arguments
    _buffer.write('$_indentation${spec.name}');
    if (spec.positionalArgs.isNotEmpty) {
      final args = spec.positionalArgs.map((a) => a.accept(this)).join(', ');
      _buffer.write('($args)');
    }
    _buffer.writeln();

    _indent = currentIndent + 1;

    // Handle properties
    for (final entry in spec.properties.entries) {
      final value = entry.value;
      if (value is DpugWidgetExpressionSpec) {
        _buffer.write('$_indentation..${entry.key}: ');
        final widgetCode = value.builder.build().accept(this);
        _buffer.write(widgetCode.trimLeft());
      } else if (value is DpugReferenceSpec && value.name.contains('{')) {
        _buffer.write('$_indentation..${entry.key}: ');
        final methodBody = _formatMethodBody(value.name, _indent - 1);
        _buffer.writeln(methodBody);
      } else {
        _buffer.writeln('$_indentation..${entry.key}: ${value.accept(this)}');
      }
    }

    // Handle positional cascade arguments
    for (final arg in spec.positionalCascadeArgs) {
      if (arg is DpugStringLiteralSpec) {
        _buffer.writeln('$_indentation..\'${arg.value}\'');
      } else {
        _buffer.writeln('$_indentation..${arg.accept(this)}');
      }
    }

    // Handle automatic child/children syntax sugar
    if (spec.shouldUseChildSugar) {
      for (final child in spec.children) {
        _buffer.write(child.accept(this));
      }
    }

    _indent = currentIndent;
    return _buffer.toString();
  }

  @override
  String visitBinary(DpugBinarySpec spec) {
    return '${spec.left.accept(this)} ${spec.operator} ${spec.right.accept(this)}';
  }

  @override
  String visitInvoke(DpugInvokeSpec spec) {
    final args = spec.arguments.map((a) => a.accept(this));
    final namedArgs = spec.namedArguments.entries
        .map((e) => '${e.key}: ${e.value.accept(this)}');

    final allArgs = [...args, ...namedArgs].join(', ');
    return '${spec.target}($allArgs)';
  }

  @override
  String visitLiteral(DpugLiteralSpec spec) {
    return spec.value.toString();
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
  String visitReference(DpugReferenceSpec spec) {
    return spec.name;
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
  String visitStateField(DpugStateFieldSpec spec) {
    final annotation = spec.annotation.accept(this);
    final initializer = _formatInitializer(spec);
    return '$_indentation$annotation ${spec.type} ${spec.name}$initializer';
  }

  @override
  String visitAnnotation(DpugAnnotationSpec spec) {
    final args = spec.arguments.map((a) => a.accept(this)).join(', ');
    return '@${spec.name}${args.isEmpty ? '' : '($args)'}';
  }

  @override
  String visitAssignment(DpugAssignmentSpec spec) {
    return '${spec.target} = ${spec.value.accept(this)}';
  }

  String _formatInitializer(DpugStateFieldSpec field) {
    return field.initializer != null
        ? ' = ${field.initializer!.accept(this)}'
        : '';
  }

  String _formatMethodBody(String code, int baseIndent) {
    final lines = code.split('\n');
    final formattedLines = <String>[];
    var currentIndent = baseIndent;
    var bracketCount = 0;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      if (i == 0) {
        formattedLines.add(line);
        if (line.endsWith('{')) bracketCount++;
        continue;
      }

      bracketCount += '{'.allMatches(line).length;
      bracketCount -= '}'.allMatches(line).length;

      if (line.startsWith('}')) {
        currentIndent = baseIndent + bracketCount;
        formattedLines.add('${config.indent * currentIndent}$line');
      } else {
        currentIndent = baseIndent + bracketCount;
        formattedLines.add('${config.indent * currentIndent}$line');
      }

      if (line.endsWith('{')) bracketCount++;
    }

    return formattedLines.join('\n');
  }
}
