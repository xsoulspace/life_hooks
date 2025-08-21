import 'dart:io';

import 'package:args/args.dart';
import 'package:dpug_code_builder/dpug_code_builder.dart';

import 'dpug_parser.dart';

/// DPug code formatter with configurable options
class DpugFormatter {
  DpugFormatter({final DpugConfig? config})
    : config = config ?? DpugConfig.readable();
  final DpugConfig config;

  /// Format DPug source code
  String format(final String source) {
    try {
      // Parse the source
      final parser = DPugParser();
      final result = parser.parse(source);

      // Check if parsing was successful
      try {
        result.value; // This will throw if parsing failed
        // For now, return the source as-is
        // TODO: Implement proper formatting logic
        return source;
      } catch (e) {
        throw FormatException(
          'Parse error: ${result.message} at position ${result.position}',
        );
      }
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
