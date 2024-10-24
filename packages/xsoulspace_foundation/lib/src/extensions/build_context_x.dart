import 'package:flutter/material.dart';

/// Extension methods for [BuildContext] to simplify access to theme data.
///
/// This extension provides convenient access to the current theme, text theme,
/// and color scheme from the [BuildContext].
///
/// @ai Use this extension to easily retrieve theme-related information in your
/// widgets without repetitive code.
extension XSBuildContextX on BuildContext {
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

  /// Retrieves the view padding for the current context.
  ///
  /// This method calculates the padding by comparing the [View] padding
  /// and the [MediaQuery] padding, returning the greater value for each side.
  ///
  /// @ai Use this method to obtain accurate padding values for your widgets,
  /// especially when dealing with safe areas and insets.
  EdgeInsets get viewPadding {
    final view = View.of(this);
    final vPad = EdgeInsets.only(
      top: view.padding.top / view.devicePixelRatio,
      bottom: view.padding.bottom / view.devicePixelRatio,
      left: view.padding.left / view.devicePixelRatio,
      right: view.padding.right / view.devicePixelRatio,
    );
    final cPad = MediaQuery.paddingOf(this);

    return EdgeInsets.only(
      top: vPad.top > cPad.top ? vPad.top : cPad.top,
      bottom: vPad.bottom > cPad.bottom ? vPad.bottom : cPad.bottom,
      left: vPad.left > cPad.left ? vPad.left : cPad.left,
      right: vPad.right > cPad.right ? vPad.right : cPad.right,
    );
  }
}
