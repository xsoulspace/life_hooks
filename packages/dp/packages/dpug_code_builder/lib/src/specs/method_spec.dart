import 'package:built_collection/built_collection.dart';

import '../visitors/visitors.dart';
import 'code_spec.dart';
import 'parameter_spec.dart';
import 'spec.dart';

class DpugMethodSpec extends DpugSpec {
  final String name;
  final String returnType;
  final BuiltList<DpugParameterSpec> parameters;
  final DpugCodeSpec body;
  final bool isGetter;

  DpugMethodSpec({
    required this.name,
    required this.returnType,
    Iterable<DpugParameterSpec> parameters = const [],
    required this.body,
    this.isGetter = false,
  }) : parameters = BuiltList<DpugParameterSpec>.of(parameters);

  factory DpugMethodSpec.getter({
    required String name,
    required String returnType,
    required DpugCodeSpec body,
  }) =>
      DpugMethodSpec(
          name: name, returnType: returnType, body: body, isGetter: true);

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitMethod(this, context);
}
