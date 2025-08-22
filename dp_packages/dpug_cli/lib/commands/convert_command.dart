import 'dart:io';

import 'package:args/command_runner.dart';

import '../dpug_cli.dart';

/// Convert between DPug and Dart command
class ConvertCommand extends Command {
  ConvertCommand() {
    argParser
      ..addOption(
        'from',
        abbr: 'f',
        help: 'Input file to convert',
        mandatory: true,
      )
      ..addOption(
        'to',
        abbr: 't',
        help: 'Output file (if not specified, prints to stdout)',
      )
      ..addOption(
        'format',
        help: 'Conversion format: dpug-to-dart or dart-to-dpug',
        allowed: ['dpug-to-dart', 'dart-to-dpug'],
        defaultsTo: 'dpug-to-dart',
      )
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Show detailed output',
        negatable: false,
      );
  }
  @override
  String get name => 'convert';

  @override
  String get description => 'Convert between DPug and Dart syntax';

  @override
  String get invocation => 'dpug convert [options]';

  @override
  Future<void> run() async {
    final args = argResults;
    if (args == null) return;

    final inputPath = args['from'] as String;
    final outputPath = args['to'] as String?;
    final format = args['format'] as String;
    final verbose = args['verbose'] as bool;

    if (!File(inputPath).existsSync()) {
      DpugCliUtils.printError('Input file not found: $inputPath');
      exit(1);
    }

    try {
      final input = await File(inputPath).readAsString();
      final converted = await _convert(input, format);

      if (outputPath != null) {
        await File(outputPath).writeAsString(converted);
        if (verbose) {
          DpugCliUtils.printSuccess('Converted $inputPath -> $outputPath');
        }
      } else {
        print(converted);
      }
    } catch (e) {
      DpugCliUtils.printError('Failed to convert $inputPath: $e');
      exit(1);
    }
  }

  Future<String> _convert(final String input, final String format) async {
    // TODO: Import and use the actual converter from dpug_core
    // For now, return input as-is
    return input;
  }
}
