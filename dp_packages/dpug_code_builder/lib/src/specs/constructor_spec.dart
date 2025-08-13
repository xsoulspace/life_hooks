import 'package:built_collection/built_collection.dart';

import '../visitors/visitors.dart';
import 'annotation_spec.dart';
import 'parameter_spec.dart';
import 'reference_spec.dart';
import 'spec.dart';

class DpugConstructorSpec extends DpugSpec {
  final String? name;
  final BuiltList<DpugParameterSpec> optionalParameters;
  final BuiltList<DpugParameterSpec> requiredParameters;
  final BuiltList<DpugReferenceSpec> initializers;
  final BuiltList<DpugAnnotationSpec> annotations;
  final DpugSpec? body;
  final bool isConst;
  final BuiltList<String> docs;
  final bool factory;
  final bool external;
  final bool lambda;
  final DpugReferenceSpec? redirect;

  DpugConstructorSpec({
    this.name,
    final Iterable<DpugParameterSpec> optionalParameters = const [],
    final Iterable<DpugParameterSpec> requiredParameters = const [],
    final Iterable<DpugReferenceSpec> initializers = const [],
    final Iterable<DpugAnnotationSpec> annotations = const [],
    this.body,
    this.isConst = false,
    this.factory = false,
    this.external = false,
    this.lambda = false,
    this.redirect,
    final Iterable<String> docs = const [],
  })  : optionalParameters = BuiltList<DpugParameterSpec>(optionalParameters),
        requiredParameters = BuiltList<DpugParameterSpec>(requiredParameters),
        initializers = BuiltList<DpugReferenceSpec>(initializers),
        annotations = BuiltList<DpugAnnotationSpec>(annotations),
        docs = BuiltList<String>(docs);

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitConstructor(this, context);
}
