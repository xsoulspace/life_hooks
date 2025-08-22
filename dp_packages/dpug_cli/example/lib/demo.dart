#!/usr/bin/env dart
// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:io';

/// DPUG CLI Demo Script
/// This script demonstrates the DPUG CLI functionality with example files
void main() async {
  print('🎯 DPUG CLI Demo');
  print('==================');
  print('');

  // Check if dpug CLI is available
  final dpugCheck = await Process.run('which', ['dpug']);
  if (dpugCheck.exitCode != 0) {
    print('❌ dpug CLI not found. Please install it first:');
    print('   dart pub global activate dpug');
    exit(1);
  }

  print('✅ DPUG CLI is available');
  print('');

  // Demo 1: Convert DPUG to Dart
  print('🔄 Demo 1: Converting DPUG to Dart');
  print('-----------------------------------');

  print('📝 Converting counter_widget.dpug to Dart...');
  final convert1 = await Process.run('dpug', [
    'convert',
    '--from',
    'counter_widget.dpug',
    '--to',
    'counter_widget_converted.dart',
    '--format',
    'dpug-to-dart',
  ]);

  if (convert1.exitCode == 0) {
    print('✅ Conversion successful!');
    print('📄 Generated Dart code:');
    print('----------------------------------------');

    try {
      final file = File('counter_widget_converted.dart');
      if (file.existsSync()) {
        final lines = await file.readAsLines();
        for (var i = 0; i < lines.length && i < 20; i++) {
          print(lines[i]);
        }
      }
    } catch (e) {
      print('Error reading converted file: $e');
    }

    print('----------------------------------------');
    print('');
  } else {
    print('❌ Conversion failed: ${convert1.stderr}');
  }

  // Demo 2: Convert Dart to DPUG
  print('🔄 Demo 2: Converting Dart to DPUG');
  print('-----------------------------------');

  print('📝 Converting counter_widget.dart to DPUG...');
  final convert2 = await Process.run('dpug', [
    'convert',
    '--from',
    'counter_widget.dart',
    '--to',
    'counter_widget_from_dart.dpug',
    '--format',
    'dart-to-dpug',
  ]);

  if (convert2.exitCode == 0) {
    print('✅ Conversion successful!');
    print('📄 Generated DPUG code:');
    print('----------------------------------------');

    try {
      final file = File('counter_widget_from_dart.dpug');
      if (file.existsSync()) {
        final lines = await file.readAsLines();
        for (var i = 0; i < lines.length && i < 20; i++) {
          print(lines[i]);
        }
      }
    } catch (e) {
      print('Error reading converted file: $e');
    }

    print('----------------------------------------');
    print('');
  } else {
    print('❌ Conversion failed: ${convert2.stderr}');
  }

  // Demo 3: Format DPUG file
  print('🎨 Demo 3: Formatting DPUG file');
  print('--------------------------------');

  print('📝 Formatting todo_list.dpug...');
  final format = await Process.run('dpug', [
    'format',
    'todo_list.dpug',
    '--verbose',
  ]);

  if (format.exitCode == 0) {
    print('✅ Formatting completed');
    print(format.stdout);
  } else {
    print('❌ Formatting failed: ${format.stderr}');
  }

  // Demo 4: Round-trip conversion test
  print('🔄 Demo 4: Round-trip conversion test');
  print('--------------------------------------');

  print('📝 Testing DPUG → Dart → DPUG conversion...');

  // Step 1: DPUG to Dart
  final step1 = await Process.run('dpug', [
    'convert',
    '--from',
    'counter_widget.dpug',
    '--format',
    'dpug-to-dart',
  ]);

  if (step1.exitCode == 0) {
    // Write intermediate Dart file
    await File('temp_counter.dart').writeAsString(step1.stdout);

    // Step 2: Dart to DPUG
    final step2 = await Process.run('dpug', [
      'convert',
      '--from',
      'temp_counter.dart',
      '--format',
      'dart-to-dpug',
    ]);

    if (step2.exitCode == 0) {
      await File('temp_counter_roundtrip.dpug').writeAsString(step2.stdout);

      print('📄 Original DPUG (first 10 lines):');
      try {
        final original = await File('counter_widget.dpug').readAsLines();
        for (var i = 0; i < original.length && i < 10; i++) {
          print(original[i]);
        }
      } catch (e) {
        print('Error reading original: $e');
      }

      print('');
      print('📄 Round-trip DPUG (first 10 lines):');
      try {
        final roundtrip = await File(
          'temp_counter_roundtrip.dpug',
        ).readAsLines();
        for (var i = 0; i < roundtrip.length && i < 10; i++) {
          print(roundtrip[i]);
        }
      } catch (e) {
        print('Error reading roundtrip: $e');
      }
    } else {
      print('❌ Round-trip step 2 failed: ${step2.stderr}');
    }
  } else {
    print('❌ Round-trip step 1 failed: ${step1.stderr}');
  }

  // Cleanup
  final files = [
    'counter_widget_converted.dart',
    'counter_widget_from_dart.dpug',
    'temp_counter.dart',
    'temp_counter_roundtrip.dpug',
  ];

  for (final file in files) {
    try {
      final f = File(file);
      if (f.existsSync()) {
        f.deleteSync();
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  print('');
  print('🎉 Demo completed!');
  print('==================');
  print('Check the example files to see more DPUG syntax examples.');
}
