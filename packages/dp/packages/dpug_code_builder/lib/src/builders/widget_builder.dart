import 'package:built_collection/built_collection.dart';
import 'package:dpug/dpug.dart';

class DpugWidgetBuilder extends DpugClassBuilder implements DpugSpec {
  String _name = '';
  final ListBuilder<DpugWidgetSpec> _children = ListBuilder<DpugWidgetSpec>();
  final MapBuilder<String, DpugExpressionSpec> _properties =
      MapBuilder<String, DpugExpressionSpec>();
  final ListBuilder<DpugExpressionSpec> _positionalArgs =
      ListBuilder<DpugExpressionSpec>();
  final ListBuilder<DpugExpressionSpec> _positionalCascadeArgs =
      ListBuilder<DpugExpressionSpec>();

  DpugWidgetBuilder child(DpugWidgetBuilder child) {
    _children.add(child.build() as DpugWidgetSpec);
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

  @override
  DpugClassSpec build() {
    if (_name.isEmpty) {
      throw StateError('Widget name must be set');
    }

    return DpugWidgetSpec.build(
      name: _name,
      children: _children.build(),
      properties: _properties.build(),
      positionalArgs: _positionalArgs.build(),
      positionalCascadeArgs: _positionalCascadeArgs.build(),
    ) as DpugClassSpec;
  }

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      build().accept(visitor, context);
}
