import 'package:built_collection/built_collection.dart';

import 'parameter_spec.dart';
import 'reference_spec.dart';
import 'spec.dart';
import '../visitors/visitors.dart';

class DpugConstructorSpec extends DpugSpec {
  final String? name;
  final BuiltList<DpugParameterSpec> parameters;
  final BuiltList<DpugReferenceSpec> initializers;
  final DpugSpec? body;
  final bool isConst;
  final bool isFactory;

  DpugConstructorSpec({
    this.name,
    Iterable<DpugParameterSpec> parameters = const [],
    Iterable<DpugReferenceSpec> initializers = const [],
    this.body,
    this.isConst = false,
    this.isFactory = false,
  })  : parameters = BuiltList<DpugParameterSpec>.of(parameters),
        initializers = BuiltList<DpugReferenceSpec>.of(initializers);

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitConstructor(this);
}
