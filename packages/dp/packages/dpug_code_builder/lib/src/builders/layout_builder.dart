import '../specs/specs.dart';
import 'widget_builder.dart';

class LayoutBuilder {
  static DpugWidgetBuilder column({
    List<DpugWidgetBuilder> children = const [],
    Map<String, DpugExpressionSpec> properties = const {},
  }) {
    final builder = DpugWidgetBuilder()..name('Column');

    for (final prop in properties.entries) {
      builder.property(prop.key, prop.value);
    }

    for (final child in children) {
      builder.child(child);
    }

    return builder;
  }

  static DpugWidgetBuilder row({
    List<DpugWidgetBuilder> children = const [],
    Map<String, DpugExpressionSpec> properties = const {},
  }) {
    final builder = DpugWidgetBuilder()..name('Row');

    for (final prop in properties.entries) {
      builder.property(prop.key, prop.value);
    }

    for (final child in children) {
      builder.child(child);
    }

    return builder;
  }
}
