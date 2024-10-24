import 'package:flutter/widgets.dart';

/// Extension methods for [Widget] to provide additional functionality.
///
/// This extension adds useful methods for manipulating widgets, enhancing their
/// capabilities for various use cases.
///
/// @ai Use this extension to simplify widget operations in your code.
extension XSWidgetX on Widget {
  /// Converts the widget to a [Sliver] using a [SliverToBoxAdapter].
  ///
  /// @returns A [SliverToBoxAdapter] containing this widget.
  ///
  /// @ai Use this method to easily integrate non-sliver widgets into sliver
  /// lists or scroll views.
  Widget toSliver() => SliverToBoxAdapter(child: this);
}
