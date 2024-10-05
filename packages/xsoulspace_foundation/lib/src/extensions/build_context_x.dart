import 'package:flutter/material.dart';

/// Extension methods for [BuildContext] to simplify access to theme data.
///
/// This extension provides convenient access to the current theme, text theme,
/// and color scheme from the [BuildContext].
///
/// @ai Use this extension to easily retrieve theme-related information in your
/// widgets without repetitive code.
extension BuildContextX on BuildContext {
  /// The current [ThemeData] for the context.
  ///
  /// @ai Use this property to access theme-related properties such as colors,
  /// fonts, and styles.
  ThemeData get theme => Theme.of(this);

  /// The current [TextTheme] for the context.
  ///
  /// @ai Use this property to access text styles defined in the current theme.
  TextTheme get textTheme => theme.textTheme;

  /// The current [ColorScheme] for the context.
  ///
  /// @ai Use this property to access color definitions for the current theme,
  /// ensuring consistent color usage throughout your application.
  ColorScheme get colorScheme => theme.colorScheme;
}
