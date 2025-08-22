/// Unified CLI framework for DPug
library;

import 'dart:io';

// ignore: avoid_classes_with_only_static_members
/// Utility functions for CLI commands
class DpugCliUtils {
  /// Print success message
  static void printSuccess(final String message) {
    print('✓ $message');
  }

  /// Print error message to stderr
  static void printError(final String message) {
    stderr.writeln('✗ $message');
  }

  /// Print info message
  static void printInfo(final String message) {
    print('ℹ $message');
  }
}
