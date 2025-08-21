import 'dart:io';

import 'package:dpug_core/compiler/dpug_formatter.dart';
import 'package:dpug_core/dpug_core.dart';

void main(final List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart format.dart <dpug_file> [output_file]');
    print('Formats a DPug file using the DPug formatter.');
    exit(1);
  }

  final inputFile = args[0];
  final outputFile = args.length > 1 ? args[1] : null;

  try {
    final input = File(inputFile).readAsStringSync();
    final formatter = DpugFormatter();
    final formatted = formatter.format(input);

    if (outputFile != null) {
      File(outputFile).writeAsStringSync(formatted);
      print('Formatted $inputFile and saved to $outputFile');
    } else {
      // Overwrite original file
      File(inputFile).writeAsStringSync(formatted);
      print('Formatted $inputFile');
    }
  } on Object catch (e) {
    print('Error formatting file: $e');
    exit(1);
  }
}
