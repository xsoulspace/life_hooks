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
    // Use the dpug_core converter
    final tempDir = Directory.systemTemp;
    final tempFile = File(
      '${tempDir.path}/temp_convert_${DateTime.now().millisecondsSinceEpoch}.dpug',
    );

    try {
      // Write input to temp file
      await tempFile.writeAsString(input);

      // Determine output file extension based on format
      final outputExt = format == 'dpug-to-dart' ? 'dart' : 'dpug';
      final outputFile = File(
        '${tempDir.path}/temp_convert_output_${DateTime.now().millisecondsSinceEpoch}.$outputExt',
      );

      // Use the dpug_core converter by importing it directly
      // For now, we'll use a simple approach by calling the converter programmatically
      if (format == 'dpug-to-dart') {
        // Import and use dpug_core converter
        final converter = await _getDpugToDartConverter();
        final result = converter.dpugToDart(input);
        return result;
      } else {
        // For dart-to-dpug, we'd need more complex setup
        // For now, return a placeholder
        return '// Converted from Dart to DPug\n$input';
      }
    } finally {
      // Cleanup temp files
      if (tempFile.existsSync()) tempFile.deleteSync();
    }
  }

  Future<_SimpleConverter> _getDpugToDartConverter() async {
    // This would normally import the converter from dpug_core
    // For now, we'll create a simple placeholder
    return _SimpleConverter();
  }
}

class _SimpleConverter {
  String dpugToDart(final String input) {
    // Placeholder implementation - in real implementation,
    // this would use the actual dpug_core converter
    return '''
// Generated from DPug
class GeneratedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Converted from: $input'),
    );
  }
}
''';
  }
}
