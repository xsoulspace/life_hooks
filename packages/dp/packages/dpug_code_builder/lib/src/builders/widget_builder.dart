import '../specs/specs.dart';

class DpugWidgetBuilder {
  String? _name;
  final List<DpugWidgetSpec> _children = [];
  final Map<String, DpugExpressionSpec> _properties = {};

  DpugWidgetBuilder name(String name) {
    _name = name;
    return this;
  }

  DpugWidgetBuilder child(DpugWidgetSpec child) {
    _children.add(child);
    return this;
  }

  DpugWidgetBuilder property(String name, DpugExpressionSpec value) {
    _properties[name] = value;
    return this;
  }

  DpugWidgetSpec build() {
    if (_name == null) {
      throw StateError('Widget name must be set');
    }

    return DpugWidgetSpec(
      name: _name!,
      children: _children,
      properties: _properties,
    );
  }
}
