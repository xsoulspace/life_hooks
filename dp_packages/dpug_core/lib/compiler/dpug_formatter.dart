import 'dart:io';

import 'package:args/args.dart';
import 'package:dpug_code_builder/dpug_code_builder.dart';

import 'ast_builder.dart';
import 'lexer.dart';

/// DPug code formatter with configurable options
class DpugFormatter {
  DpugFormatter({final DpugConfig? config})
    : config = config ?? DpugConfig.readable();
  final DpugConfig config;

  /// Format DPug source code
  String format(final String source) {
    try {
      // Parse the source using the AST builder
      final tokens = Lexer(source).tokenize();
      final ast = ASTBuilder(tokens).build();

      // Format the AST back to DPug code
      final formatter = _DpugAstFormatter(config);
      return formatter.format(ast).trim();
    } catch (e) {
      if (e is FormatException) rethrow;
      throw FormatException('Formatting failed: $e');
    }
  }

  /// Format a file in-place
  Future<void> formatFile(final String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw FileSystemException('File not found', path);
    }

    final source = await file.readAsString();
    final formatted = format(source);

    if (source != formatted) {
      await file.writeAsString(formatted);
      print('Formatted: $path');
    } else {
      print('Already formatted: $path');
    }
  }

  /// Format multiple files
  Future<void> formatFiles(final List<String> paths) async {
    for (final path in paths) {
      try {
        await formatFile(path);
      } catch (e) {
        print('Error formatting $path: $e');
      }
    }
  }
}

/// AST-based formatter that converts parsed AST back to formatted DPug code
class _DpugAstFormatter {
  _DpugAstFormatter(this.config);
  final DpugConfig config;

  String format(final ASTNode node) {
    if (node is ClassNode) {
      return _formatClass(node);
    } else if (node is WidgetNode) {
      return _formatWidget(node);
    }
    return '';
  }

  String _formatClass(final ClassNode node) {
    final buffer = StringBuffer();

    // Annotations
    for (final annotation in node.annotations) {
      buffer.writeln('@$annotation');
    }

    // Class declaration
    buffer.write('class ${node.name}');

    if (node.stateVariables.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(_indent(''));
      for (final field in node.stateVariables) {
        buffer.writeln(
          _indent('@${field.annotation} ${field.type} ${field.name}'),
        );
      }
    }

    if (node.methods.isNotEmpty) {
      buffer.writeln();
      for (final method in node.methods) {
        buffer.writeln(_indent(_formatMethod(method)));
      }
    }

    return buffer.toString();
  }

  String _formatMethod(final MethodNode node) {
    final buffer = StringBuffer();
    buffer.write('Widget get ${node.name} =>');
    buffer.write('\n');
    if (node.body is WidgetNode) {
      buffer.write(_indent(_formatWidget(node.body as WidgetNode)));
    } else {
      buffer.write(_indent('widget'));
    }
    return buffer.toString();
  }

  String _formatWidget(final WidgetNode node) {
    final buffer = StringBuffer();
    buffer.write(node.name);

    // Add positional arguments
    if (node.positionalArgs.isNotEmpty) {
      buffer.write('(');
      for (var i = 0; i < node.positionalArgs.length; i++) {
        if (i > 0) buffer.write(', ');
        buffer.write(_formatExpression(node.positionalArgs[i]));
      }
      buffer.write(')');
    }

    // Add properties
    if (node.properties.isNotEmpty) {
      buffer.writeln();
      for (final entry in node.properties.entries) {
        buffer.writeln(
          _indent('..${entry.key}: ${_formatExpression(entry.value)}'),
        );
      }
    }

    // Add children
    if (node.children.isNotEmpty) {
      buffer.writeln();
      for (final child in node.children) {
        if (child is WidgetNode) {
          buffer.writeln(_indent(_formatWidget(child)));
        } else {
          buffer.writeln(_indent('widget'));
        }
      }
    }

    return buffer.toString();
  }

  String _formatExpression(final Expression node) {
    if (node is StringExpression) {
      return '"${node.value}"';
    } else if (node is NumberExpression) {
      return node.value.toString();
    } else if (node is BooleanExpression) {
      return node.value.toString();
    } else if (node is IdentifierExpression) {
      return node.name;
    }
    return 'expression';
  }

  String _indent(final String text) {
    if (text.isEmpty) return '';
    return text
        .split('\n')
        .map((final line) => '${config.indent}$line')
        .join('\n');
  }
}

/// CLI tool for DPug formatting
class DpugFormatCommand {
  final ArgParser parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help')
    ..addFlag('compact', negatable: false, help: 'Use compact formatting')
    ..addFlag(
      'readable',
      negatable: false,
      help: 'Use readable formatting (default)',
    )
    ..addOption(
      'indent',
      abbr: 'i',
      help: 'Indentation string (default: 2 spaces)',
    )
    ..addFlag(
      'check',
      negatable: false,
      help: 'Check if files are formatted without modifying',
    );

  Future<void> run(final List<String> args) async {
    try {
      final results = parser.parse(args);

      if (results['help'] as bool) {
        _printUsage();
        return;
      }

      final files = results.rest;
      if (files.isEmpty) {
        print('Error: No files specified');
        _printUsage();
        exit(1);
      }

      // Build configuration
      DpugConfig config;
      if (results['compact'] as bool) {
        config = DpugConfig.compact();
      } else {
        config = DpugConfig.readable();
      }

      if (results['indent'] != null) {
        config = DpugConfig(
          indent: results['indent'] as String,
          spaceBetweenMembers: config.spaceBetweenMembers,
          spaceBetweenProperties: config.spaceBetweenProperties,
          spaceAfterAnnotations: config.spaceAfterAnnotations,
          spaceBetweenCascades: config.spaceBetweenCascades,
        );
      }

      final formatter = DpugFormatter(config: config);
      final checkOnly = results['check'] as bool;

      if (checkOnly) {
        await _checkFormatting(formatter, files);
      } else {
        await formatter.formatFiles(files);
      }
    } catch (e) {
      print('Error: $e');
      exit(1);
    }
  }

  Future<void> _checkFormatting(
    final DpugFormatter formatter,
    final List<String> files,
  ) async {
    bool hasUnformatted = false;

    for (final path in files) {
      try {
        final file = File(path);
        final source = await file.readAsString();
        final formatted = formatter.format(source);

        if (source != formatted) {
          print('Needs formatting: $path');
          hasUnformatted = true;
        } else {
          print('Formatted correctly: $path');
        }
      } catch (e) {
        print('Error checking $path: $e');
        hasUnformatted = true;
      }
    }

    if (hasUnformatted) {
      exit(1);
    }
  }

  void _printUsage() {
    print('DPug Formatter');
    print('');
    print('Usage: dpug_format [options] <files...>');
    print('');
    print('Options:');
    print(parser.usage);
    print('');
    print('Examples:');
    print('  dpug_format lib/*.dpug');
    print('  dpug_format --compact --indent="  " lib/');
    print('  dpug_format --check lib/');
  }
}

/// Main entry point for CLI
Future<void> main(final List<String> args) async {
  final command = DpugFormatCommand();
  await command.run(args);
}
