import '../specs/specs.dart';
import 'widget_builder.dart';

/// Helper class that provides syntax sugar for common widget patterns
class WidgetHelpers {
  /// Creates a widget with children, automatically wrapping them in a children property
  static DpugWidgetBuilder withChildren(
    String name, {
    List<DpugWidgetBuilder> children = const [],
    Map<String, DpugExpressionSpec> properties = const {},
  }) {
    final builder = DpugWidgetBuilder()..name(name);

    for (final prop in properties.entries) {
      builder.property(prop.key, prop.value);
    }

    for (final child in children) {
      builder.child(child);
    }

    return builder;
  }

  /// Shorthand for Column with children
  static DpugWidgetBuilder column({
    List<DpugWidgetBuilder> children = const [],
    Map<String, DpugExpressionSpec> properties = const {},
  }) {
    return withChildren('Column', children: children, properties: properties);
  }

  /// Shorthand for Row with children
  static DpugWidgetBuilder row({
    List<DpugWidgetBuilder> children = const [],
    Map<String, DpugExpressionSpec> properties = const {},
  }) {
    return withChildren('Row', children: children, properties: properties);
  }

  /// Shorthand for Stack with children
  static DpugWidgetBuilder stack({
    List<DpugWidgetBuilder> children = const [],
    Map<String, DpugExpressionSpec> properties = const {},
  }) {
    return withChildren('Stack', children: children, properties: properties);
  }

  /// Shorthand for ListView with children
  static DpugWidgetBuilder listView({
    List<DpugWidgetBuilder> children = const [],
    Map<String, DpugExpressionSpec> properties = const {},
  }) {
    return withChildren('ListView', children: children, properties: properties);
  }
}
