import 'package:built_collection/built_collection.dart';

import '../visitors/visitors.dart';
import 'specs.dart';

class DpugWidgetSpec extends DpugSpec {
  final String name;
  final BuiltList<DpugWidgetSpec> children;
  final BuiltMap<String, DpugExpressionSpec> properties;
  final BuiltList<DpugExpressionSpec> positionalArgs;
  final BuiltList<DpugExpressionSpec> positionalCascadeArgs;

  bool get hasExplicitChild => properties.containsKey('child');
  bool get hasExplicitChildren => properties.containsKey('children');
  bool get shouldUseChildSugar =>
      children.isNotEmpty && !hasExplicitChild && !hasExplicitChildren;
  bool get isSingleChild => children.length == 1;

  factory DpugWidgetSpec({
    required String name,
    Iterable<DpugWidgetSpec> children = const [],
    Map<String, DpugExpressionSpec> properties = const {},
    Iterable<DpugExpressionSpec> positionalArgs = const [],
    Iterable<DpugExpressionSpec> positionalCascadeArgs = const [],
  }) {
    return DpugWidgetSpec.build(
      name: name,
      children: BuiltList<DpugWidgetSpec>.of(children),
      properties: BuiltMap<String, DpugExpressionSpec>.of(properties),
      positionalArgs: BuiltList<DpugExpressionSpec>.of(positionalArgs),
      positionalCascadeArgs:
          BuiltList<DpugExpressionSpec>.of(positionalCascadeArgs),
    );
  }

  const DpugWidgetSpec.build({
    required this.name,
    required this.children,
    required this.properties,
    required this.positionalArgs,
    required this.positionalCascadeArgs,
  });

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitWidget(this);
}
