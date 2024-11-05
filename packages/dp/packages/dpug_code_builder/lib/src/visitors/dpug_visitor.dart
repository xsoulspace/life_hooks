import '../formatters/dpug_config.dart';
import '../formatters/dpug_formatter.dart';
import '../specs/specs.dart';
import 'visitor.dart';

/// converts Dpug to Strings
class DpugGeneratingVisitor implements DpugSpecVisitor<String> {
  final DpugFormatter _formatter;
  int _indent = 0;

  DpugGeneratingVisitor([DpugConfig? config])
      : _formatter = DpugFormatter(config ?? const DpugConfig());

  @override
  String visitClass(DpugClassSpec spec) {
    final localBuffer = StringBuffer();
    _indent = 0;

    // Write class declaration and annotations
    for (final annotation in spec.annotations) {
      localBuffer.writeln(annotation.accept(this));
    }
    localBuffer.writeln('class ${spec.name}');
    _indent++;

    // Write state fields with inline annotations
    for (final field in spec.stateFields) {
      final annotation = field.annotation.accept(this);
      final initializer = _formatInitializer(field);
      localBuffer.writeln(
          '${_formatter.config.indent * _indent}$annotation ${field.type} ${field.name}$initializer');
    }

    // Write methods
    if (spec.methods.isNotEmpty) {
      localBuffer.writeln(''); // Single newline before methods
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
      localBuffer
          .writeln('${_formatter.config.indent * _indent}Widget get build =>');
      _indent++;
      final bodyCode = spec.body.accept(this);
      localBuffer.write(bodyCode);
      _indent--;
    } else if (spec.isGetter) {
      localBuffer.writeln(
          '${_formatter.config.indent * _indent}${spec.returnType} get ${spec.name} =>');
      _indent++;
      final bodyCode = spec.body.accept(this);
      localBuffer.write(bodyCode);
      _indent--;
    } else {
      final params = spec.parameters.map((p) => p.accept(this)).join(', ');
      localBuffer.writeln(
          '${_formatter.config.indent * _indent}${spec.returnType} ${spec.name}($params) =>');
      _indent++;
      final bodyCode = spec.body.accept(this);
      localBuffer.write(bodyCode);
      _indent--;
    }

    return localBuffer.toString();
  }

  @override
  String visitWidget(DpugWidgetSpec spec) {
    final localBuffer = StringBuffer();
    final currentIndent = _indent;

    // Write widget name with optional positional arguments
    localBuffer
        .write('${_formatter.config.indent * currentIndent}${spec.name}');
    if (spec.positionalArgs.isNotEmpty) {
      final args = spec.positionalArgs.map((a) => a.accept(this)).join(', ');
      localBuffer.write('($args)');
    }
    localBuffer.writeln();

    _indent = currentIndent + 1;

    // Handle properties
    for (final entry in spec.properties.entries) {
      final value = entry.value;
      if (value is DpugWidgetExpressionSpec) {
        // Keep widget values at same level as property
        localBuffer
            .write('${_formatter.config.indent * _indent}..${entry.key}: ');
        final widgetCode = value.builder.build().accept(this);
        localBuffer.write(widgetCode.trimLeft());
      } else if (value is DpugReferenceSpec && value.name.contains('{')) {
        // Handle method bodies with proper indentation
        localBuffer
            .write('${_formatter.config.indent * _indent}..${entry.key}: ');
        final methodBody = _formatMethodBody(value.name, _indent - 1);
        localBuffer.writeln(methodBody);
      } else {
        localBuffer.writeln(
            '${_formatter.config.indent * _indent}..${entry.key}: ${value.accept(this)}');
      }
    }

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

    // Handle automatic child/children syntax sugar
    if (spec.shouldUseChildSugar) {
      for (final child in spec.children) {
        final childCode = child.accept(this);
        localBuffer.write(childCode);
      }
    }

    _indent = currentIndent;
    return localBuffer.toString();
  }

  String visitMultipleClasses(List<DpugClassSpec> specs) {
    return specs.map((spec) => spec.accept(this)).join('\n\n');
  }

  String _formatInitializer(DpugStateFieldSpec field) {
    return field.initializer != null
        ? ' = ${field.initializer!.accept(this)}'
        : '';
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

  @override
  String visitLambda(DpugLambdaSpec spec) {
    final params = spec.parameters.join(', ');
    return '($params) => ${spec.body.accept(this)}';
  }

  @override
  String visitListLiteral(DpugListLiteralSpec spec) {
    final values = spec.values.map((v) => v.accept(this)).join(', ');
    return '[$values]';
  }

  @override
  String visitReference(DpugReferenceSpec spec) {
    return spec.name;
  }

  @override
  String visitStringLiteral(DpugStringLiteralSpec spec) {
    // Wrap string literals in single quotes
    return "'${spec.value}'";
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
    return '${_formatter.config.indent * _indent}$annotation ${spec.type} ${spec.name}$initializer';
  }

  String _formatMethodBody(String code, int baseIndent) {
    final lines = code.split('\n');
    final formattedLines = <String>[];
    var currentIndent = baseIndent;
    var bracketCount = 0;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // First line (usually contains the method signature)
      if (i == 0) {
        formattedLines.add(line);
        if (line.endsWith('{')) bracketCount++;
        continue;
      }

      // Count opening and closing braces
      bracketCount += '{'.allMatches(line).length;
      bracketCount -= '}'.allMatches(line).length;

      // Handle closing braces
      if (line.startsWith('}')) {
        currentIndent = baseIndent + bracketCount;
        formattedLines.add('${_formatter.config.indent * currentIndent}$line');
      } else {
        // Regular lines get indented based on bracket depth
        currentIndent = baseIndent + bracketCount;
        formattedLines.add('${_formatter.config.indent * currentIndent}$line');
      }

      // If this line contains an opening brace, next line will be indented
      if (line.endsWith('{')) {
        bracketCount++;
      }
    }

    return formattedLines.join('\n');
  }
}
