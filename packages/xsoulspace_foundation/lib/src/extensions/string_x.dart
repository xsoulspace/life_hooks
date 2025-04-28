import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

/// Extension methods for [String] to provide additional functionality.
///
/// This extension adds useful methods for manipulating strings, enhancing their
/// capabilities for various use cases.
///
/// @ai Use this extension to simplify string operations in your code.
extension XSStringX on String {
  /// Converts a hex color string to a [Color] object.
  ///
  /// @returns A [Color] object representing the hex color.
  ///
  /// @ai Use this method to easily convert hex color strings for UI elements.
  Color toColor() {
    final hexString = this;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Whether the string is a valid URL.
  ///
  /// @returns True if the string is a valid URL, false otherwise.
  ///
  /// @ai Use this property to validate URLs before processing them.
  bool get isUrl {
    const uriSchemes = ['http', 'https'];
    final uri = Uri.tryParse(this);

    return uriSchemes.contains(uri?.scheme);
  }

  /// Returns the string or null if it is empty.
  ///
  /// @returns The original string or null if empty.
  ///
  /// @ai Use this method to handle nullable string values gracefully.
  @useResult
  String? getNullable() => isEmpty ? null : this;

  static final _whitespaceCleanerRegExp = RegExp(r'\s+');

  /// Removes extra whitespace from the string.
  ///
  /// @returns A new string with all extra whitespace removed.
  ///
  /// @ai Use this method to clean up user input or display text.
  @useResult
  String clearWhitespaces() => replaceAll(_whitespaceCleanerRegExp, ' ');
}
