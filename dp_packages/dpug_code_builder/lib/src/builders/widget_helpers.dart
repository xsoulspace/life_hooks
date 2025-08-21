import '../specs/specs.dart';
import 'widget_builder.dart';

// ignore: avoid_classes_with_only_static_members
/// Helper class that provides syntax sugar for common widget patterns
class WidgetHelpers {
  /// Creates a widget with children, automatically wrapping them in a children property
  static DpugWidgetBuilder withChildren(
    final String name, {
    final List<DpugWidgetBuilder> children = const [],
    final Map<String, DpugExpressionSpec> properties = const {},
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

  /// Creates a widget with a single child, automatically using the child property
  static DpugWidgetBuilder withChild(
    final String name, {
    final DpugWidgetBuilder? child,
    final Map<String, DpugExpressionSpec> properties = const {},
  }) {
    final builder = DpugWidgetBuilder()..name(name);

    for (final prop in properties.entries) {
      builder.property(prop.key, prop.value);
    }

    if (child != null) {
      builder.property('child', DpugExpressionSpec.widget(child));
    }

    return builder;
  }

  /// Shorthand for SizedBox with single child
  static DpugWidgetBuilder sizedBox({
    final DpugWidgetBuilder? child,
    final Map<String, DpugExpressionSpec> properties = const {},
  }) => withChild('SizedBox', child: child, properties: properties);

  /// Shorthand for Container with single child
  static DpugWidgetBuilder container({
    final DpugWidgetBuilder? child,
    final Map<String, DpugExpressionSpec> properties = const {},
  }) => withChild('Container', child: child, properties: properties);

  /// Shorthand for Column with children
  static DpugWidgetBuilder column({
    final List<DpugWidgetBuilder> children = const [],
    final Map<String, DpugExpressionSpec> properties = const {},
  }) => withChildren('Column', children: children, properties: properties);

  /// Shorthand for Row with children
  static DpugWidgetBuilder row({
    final List<DpugWidgetBuilder> children = const [],
    final Map<String, DpugExpressionSpec> properties = const {},
  }) => withChildren('Row', children: children, properties: properties);

  /// Shorthand for Stack with children
  static DpugWidgetBuilder stack({
    final List<DpugWidgetBuilder> children = const [],
    final Map<String, DpugExpressionSpec> properties = const {},
  }) => withChildren('Stack', children: children, properties: properties);

  /// Shorthand for ListView with children
  static DpugWidgetBuilder listView({
    final List<DpugWidgetBuilder> children = const [],
    final Map<String, DpugExpressionSpec> properties = const {},
  }) => withChildren('ListView', children: children, properties: properties);

  /// Add new helper method
  static DpugWidgetBuilder gridView({
    final List<DpugWidgetBuilder> children = const [],
    final Map<String, DpugExpressionSpec> properties = const {},
  }) => withChildren('GridView', children: children, properties: properties);

  /// For widgets with named constructor
  static DpugWidgetBuilder gridViewBuilder({
    final List<DpugWidgetBuilder> children = const [],
    final Map<String, DpugExpressionSpec> properties = const {},
  }) => withChildren(
    'GridView.builder',
    children: children,
    properties: properties,
  );
}
