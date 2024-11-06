import 'package:built_collection/built_collection.dart';

import '../visitors/visitor.dart';
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

  DpugWidgetSpec({
    required this.name,
    Iterable<DpugWidgetSpec> children = const [],
    Map<String, DpugExpressionSpec> properties = const {},
    Iterable<DpugExpressionSpec> positionalArgs = const [],
    Iterable<DpugExpressionSpec> positionalCascadeArgs = const [],
  })  : children = BuiltList<DpugWidgetSpec>.of(children),
        properties = BuiltMap<String, DpugExpressionSpec>.of(properties),
        positionalArgs = BuiltList<DpugExpressionSpec>.of(positionalArgs),
        positionalCascadeArgs =
            BuiltList<DpugExpressionSpec>.of(positionalCascadeArgs);

  factory DpugWidgetSpec.build({
    required String name,
    required BuiltList<DpugWidgetSpec> children,
    required BuiltMap<String, DpugExpressionSpec> properties,
    Iterable<DpugExpressionSpec> positionalArgs = const [],
    Iterable<DpugExpressionSpec> positionalCascadeArgs = const [],
  }) =>
      DpugWidgetSpec(
        name: name,
        children: children,
        properties: properties.toMap(),
        positionalArgs: BuiltList<DpugExpressionSpec>.of(positionalArgs),
        positionalCascadeArgs:
            BuiltList<DpugExpressionSpec>.of(positionalCascadeArgs),
      );

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitWidget(this, context);
}
