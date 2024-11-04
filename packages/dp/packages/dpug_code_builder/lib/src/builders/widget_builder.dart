import 'package:built_collection/built_collection.dart';

import '../specs/specs.dart';
import '../visitors/visitors.dart';

class DpugWidgetBuilder implements DpugSpec {
  String? _name;
  final ListBuilder<DpugWidgetSpec> _children = ListBuilder<DpugWidgetSpec>();
  final MapBuilder<String, DpugExpressionSpec> _properties =
      MapBuilder<String, DpugExpressionSpec>();
  final ListBuilder<DpugExpressionSpec> _positionalArgs =
      ListBuilder<DpugExpressionSpec>();
  final ListBuilder<DpugExpressionSpec> _positionalCascadeArgs =
      ListBuilder<DpugExpressionSpec>();

  DpugWidgetBuilder name(String name) {
    _name = name;
    return this;
  }

  DpugWidgetBuilder child(DpugWidgetBuilder child) {
    _children.add(child.build());
    return this;
  }

  DpugWidgetBuilder property(String name, DpugExpressionSpec value) {
    _properties[name] = value;
    return this;
  }

  DpugWidgetBuilder positionalArgument(DpugExpressionSpec value) {
    _positionalArgs.add(value);
    return this;
  }

  DpugWidgetBuilder positionalCascadeArgument(DpugExpressionSpec value) {
    _positionalCascadeArgs.add(value);
    return this;
  }

  DpugWidgetSpec build() {
    if (_name == null) {
      throw StateError('Widget name must be set');
    }

    return DpugWidgetSpec.build(
      name: _name!,
      children: _children.build(),
      properties: _properties.build(),
      positionalArgs: _positionalArgs.build(),
      positionalCascadeArgs: _positionalCascadeArgs.build(),
    );
  }

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => build().accept(visitor);
}
