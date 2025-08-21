import 'package:built_collection/built_collection.dart';

import '../visitors/visitors.dart';
import 'parameter_spec.dart';
import 'spec.dart';

class DpugMethodSpec extends DpugSpec {
  DpugMethodSpec({
    required this.name,
    required this.returnType,
    required this.body,
    final Iterable<DpugParameterSpec> parameters = const [],
    this.isGetter = false,
  }) : parameters = BuiltList<DpugParameterSpec>.of(parameters);

  factory DpugMethodSpec.getter({
    required final String name,
    required final String returnType,
    required final DpugSpec body,
  }) => DpugMethodSpec(
    name: name,
    returnType: returnType,
    body: body,
    isGetter: true,
  );
  final String name;
  final String returnType;
  final BuiltList<DpugParameterSpec> parameters;
  final DpugSpec body;
  final bool isGetter;

  @override
  R accept<R>(final DpugSpecVisitor<R> visitor, [final R? context]) =>
      visitor.visitMethod(this, context);

  @override
  String get code =>
      '$returnType $name(${parameters.join(', ')}) { ${body.code} }';
}
