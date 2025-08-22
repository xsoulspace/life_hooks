#!/usr/bin/env dart

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dpug_cli/commands/convert_command.dart';
import 'package:dpug_cli/commands/format_command.dart';
import 'package:dpug_cli/commands/plugins_command.dart';
import 'package:dpug_cli/commands/server_command.dart';

/// Main CLI entry point for DPug
Future<void> main(final List<String> args) async {
  final runner =
      CommandRunner(
          'dpug',
          'Unified CLI for DPug - indentation-based Flutter/Dart syntax',
        )
        ..addCommand(ConvertCommand())
        ..addCommand(FormatCommand())
        ..addCommand(ServerCommand())
        ..addCommand(PluginsCommand());

  try {
    await runner.run(args);
  } on UsageException catch (e) {
    print('Error: ${e.message}');
    print('');
    print('Usage: ${e.usage}');
    exit(1);
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}
