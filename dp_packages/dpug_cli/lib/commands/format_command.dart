import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpug_core/dpug_core.dart';

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
  ArgResults? argResults;

  @override
  String get name => 'format';

  @override
  String get description =>
      'Format DPug files with consistent indentation and spacing';

  @override
  Future<void> run() async {
    final args = argResults;
    if (args == null) {
      throw StateError('argResults not initialized');
    }

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
    try {
      final formatter = DpugFormatter();
      return formatter.format(input);
    } catch (e) {
      throw Exception('Formatting failed: $e');
    }
  }

  /// Direct method for testing - formats a file
  Future<void> formatFile(final String filePath) async {
    final args = ['--in-place', filePath];
    argResults = argParser.parse(args);
    await run();
  }

  /// Initialize argResults for testing
  void initializeArgs(final List<String> args) {
    argResults = argParser.parse(args);
  }
}
