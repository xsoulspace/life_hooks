import 'dart:io';

import 'package:args/command_runner.dart';

import '../dpug_cli.dart';

/// Format DPug files command
class FormatCommand extends Command {
  FormatCommand() {
    argParser
      ..addFlag(
        'in-place',
        abbr: 'i',
        help: 'Format files in place',
        negatable: false,
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Write output to specified file (single file only)',
      )
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Show detailed output',
        negatable: false,
      );
  }
  @override
  String get name => 'format';

  @override
  String get description =>
      'Format DPug files with consistent indentation and spacing';

  @override
  Future<void> run() async {
    final args = argResults;
    if (args == null) return;

    final files = args.rest;
    final writeInPlace = args['in-place'] as bool;
    final outputFile = args['output'] as String?;
    final verbose = args['verbose'] as bool;

    if (files.isEmpty) {
      DpugCliUtils.printError('No input files specified');
      printUsage();
      exit(1);
    }

    if (outputFile != null && files.length > 1) {
      DpugCliUtils.printError(
        'Cannot specify output file when formatting multiple files',
      );
      exit(1);
    }

    for (final file in files) {
      await _formatFile(
        file,
        writeInPlace: writeInPlace,
        outputFile: outputFile,
        verbose: verbose,
      );
    }
  }

  Future<void> _formatFile(
    final String inputPath, {
    required final bool writeInPlace,
    final String? outputFile,
    final bool verbose = false,
  }) async {
    try {
      final inputFile = File(inputPath);
      if (!inputFile.existsSync()) {
        DpugCliUtils.printError('File not found: $inputPath');
        exit(1);
      }

      // Read input
      final input = await inputFile.readAsString();

      // Format using existing formatter
      final formatted = await _callFormatter(input);

      final outputPath = outputFile ?? (writeInPlace ? inputPath : null);

      if (outputPath != null) {
        await File(outputPath).writeAsString(formatted);
        if (verbose) {
          DpugCliUtils.printSuccess('Formatted $inputPath -> $outputPath');
        }
      } else {
        // Print to stdout
        print(formatted);
      }
    } catch (e) {
      DpugCliUtils.printError('Failed to format $inputPath: $e');
      exit(1);
    }
  }

  Future<String> _callFormatter(final String input) async {
    // Use the existing dpug_format.dart tool
    final tempDir = Directory.systemTemp;
    final tempFile = File(
      '${tempDir.path}/temp_format_${DateTime.now().millisecondsSinceEpoch}.dpug',
    );
    final outputFile = File(
      '${tempDir.path}/temp_format_output_${DateTime.now().millisecondsSinceEpoch}.dpug',
    );

    try {
      // Write input to temp file
      await tempFile.writeAsString(input);

      // Run the existing formatter
      final result = await Process.run(
        'dart',
        [
          'run',
          '/Users/antonio/xs/life_hooks/dp_packages/dpug_core/bin/dpug_format.dart',
          '--output',
          outputFile.path,
          tempFile.path,
        ],
        workingDirectory: '/Users/antonio/xs/life_hooks/dp_packages/dpug_core',
      );

      if (result.exitCode != 0) {
        throw Exception('Formatter failed: ${result.stderr}');
      }

      // Read the formatted output
      final formatted = await outputFile.readAsString();
      return formatted;
    } finally {
      // Cleanup temp files
      if (tempFile.existsSync()) tempFile.deleteSync();
      if (outputFile.existsSync()) outputFile.deleteSync();
    }
  }
}
