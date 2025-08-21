#!/usr/bin/env dart

import 'dart:io';

import 'package:dpug_core/compiler/dpug_formatter.dart';

/// Standalone DPug formatter CLI tool
void main(final List<String> args) {
  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    _printUsage();
    return;
  }

  final files = <String>[];
  var writeInPlace = false;
  String? outputFile;

  // Parse arguments
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];

    switch (arg) {
      case '--in-place':
      case '-i':
        writeInPlace = true;
      case '--output':
      case '-o':
        if (i + 1 < args.length) {
          outputFile = args[++i];
        } else {
          _printError('Missing output file after $arg');
          exit(1);
        }
      default:
        if (!arg.startsWith('-')) {
          files.add(arg);
        } else {
          _printError('Unknown option: $arg');
          _printUsage();
          exit(1);
        }
    }
  }

  if (files.isEmpty) {
    _printError('No input files specified');
    _printUsage();
    exit(1);
  }

  if (outputFile != null && files.length > 1) {
    _printError('Cannot specify output file when formatting multiple files');
    exit(1);
  }

  // Format files
  for (final file in files) {
    _formatFile(file, writeInPlace: writeInPlace, outputFile: outputFile);
  }
}

void _formatFile(
  final String inputPath, {
  required final bool writeInPlace,
  final String? outputFile,
}) {
  try {
    final inputFile = File(inputPath);
    if (!inputFile.existsSync()) {
      _printError('File not found: $inputPath');
      exit(1);
    }

    final input = inputFile.readAsStringSync();
    final formatter = DpugFormatter();
    final formatted = formatter.format(input);

    final outputPath = outputFile ?? (writeInPlace ? inputPath : null);

    if (outputPath != null) {
      File(outputPath).writeAsStringSync(formatted);
      print('✓ Formatted $inputPath -> $outputPath');
    } else {
      // Print to stdout
      print(formatted);
    }
  } on Object catch (e) {
    _printError('Failed to format $inputPath: $e');
    exit(1);
  }
}

void _printUsage() {
  print('DPug Formatter');
  print('');
  print('Usage: dpug_format [options] <files...>');
  print('');
  print('Options:');
  print('  -i, --in-place    Format files in place');
  print(
    '  -o, --output <file>  Write output to specified file (single file only)',
  );
  print('  -h, --help        Show this help');
  print('');
  print('Examples:');
  print(
    '  dpug_format my_widget.dpug                    # Format and print to stdout',
  );
  print('  dpug_format -i my_widget.dpug                 # Format in place');
  print('  dpug_format -o formatted.dpug my_widget.dpug  # Format to new file');
  print(
    '  dpug_format -i *.dpug                         # Format multiple files',
  );
}

void _printError(final String message) {
  stderr.writeln('Error: $message');
}
