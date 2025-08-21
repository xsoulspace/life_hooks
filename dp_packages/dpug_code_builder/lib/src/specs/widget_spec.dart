import 'package:built_collection/built_collection.dart';

import '../visitors/visitor.dart';
import 'specs.dart';

class DpugWidgetSpec extends DpugSpec {
  DpugWidgetSpec({
    required this.name,
    final Iterable<DpugWidgetSpec> children = const [],
    final Map<String, DpugExpressionSpec> properties = const {},
    final Iterable<DpugExpressionSpec> positionalArgs = const [],
    final Iterable<DpugExpressionSpec> positionalCascadeArgs = const [],
  }) : children = BuiltList<DpugWidgetSpec>.of(children),
       properties = BuiltMap<String, DpugExpressionSpec>.of(properties),
       positionalArgs = BuiltList<DpugExpressionSpec>.of(positionalArgs),
       positionalCascadeArgs = BuiltList<DpugExpressionSpec>.of(
         positionalCascadeArgs,
       );

  factory DpugWidgetSpec.build({
    required final String name,
    required final BuiltList<DpugWidgetSpec> children,
    required final BuiltMap<String, DpugExpressionSpec> properties,
    final Iterable<DpugExpressionSpec> positionalArgs = const [],
    final Iterable<DpugExpressionSpec> positionalCascadeArgs = const [],
  }) => DpugWidgetSpec(
    name: name,
    children: children,
    properties: properties.toMap(),
    positionalArgs: BuiltList<DpugExpressionSpec>.of(positionalArgs),
    positionalCascadeArgs: BuiltList<DpugExpressionSpec>.of(
      positionalCascadeArgs,
    ),
  );
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

  @override
  R accept<R>(final DpugSpecVisitor<R> visitor, [final R? context]) =>
      visitor.visitWidget(this, context);

  @override
  String get code => name;
}
