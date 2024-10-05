import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

/// Extension methods for [String] to provide additional functionality.
///
/// This extension adds useful methods for manipulating strings, enhancing their
/// capabilities for various use cases.
///
/// @ai Use this extension to simplify string operations in your code.
extension StringX on String {
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

  /// Invokes a callback when the string is non-empty.
  ///
  /// [callback] The function to invoke with the string value.
  ///
  /// @ai Use this method to perform actions conditionally based on string
  /// content.
  void onNotEmpty(final void Function(String value) callback) =>
      isEmpty ? null : callback(this);

  /// Returns a default value if the string is empty.
  ///
  /// [value] The default value to return if the string is empty.
  /// @returns The original string or the default value if empty.
  ///
  /// @ai Use this method to provide fallback values for empty strings.
  String whenEmptyUse(final String value) => isEmpty ? value : this;

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
