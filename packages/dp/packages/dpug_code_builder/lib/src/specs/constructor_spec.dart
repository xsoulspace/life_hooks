import 'package:built_collection/built_collection.dart';

import '../visitors/visitors.dart';
import 'parameter_spec.dart';
import 'reference_spec.dart';
import 'spec.dart';

class DpugConstructorSpec extends DpugSpec {
  final String? name;
  final BuiltList<DpugParameterSpec> parameters;
  final BuiltList<DpugReferenceSpec> initializers;
  final DpugSpec? body;
  final bool isConst;
  final BuiltList<String> docs;
  final bool isFactory;

  DpugConstructorSpec({
    this.name,
    final Iterable<DpugParameterSpec> parameters = const [],
    final Iterable<DpugReferenceSpec> initializers = const [],
    this.body,
    this.isConst = false,
    this.isFactory = false,
    final Iterable<String> docs = const [],
  })  : parameters = BuiltList<DpugParameterSpec>.of(parameters),
        initializers = BuiltList<DpugReferenceSpec>.of(initializers),
        docs = BuiltList<String>.of(docs);

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitConstructor(this, context);
}
