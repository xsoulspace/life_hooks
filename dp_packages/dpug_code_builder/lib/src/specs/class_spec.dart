import 'package:built_collection/built_collection.dart';
import 'package:source_span/source_span.dart';

import '../visitors/visitor.dart';
import 'annotation_spec.dart';
import 'constructor_spec.dart';
import 'method_spec.dart';
import 'reference_spec.dart';
import 'spec.dart';
import 'state_field_spec.dart';

class DpugClassSpec implements DpugSpec {
  DpugClassSpec({
    required this.name,
    final Iterable<DpugAnnotationSpec> annotations = const [],
    final Iterable<DpugStateFieldSpec> stateFields = const [],
    final Iterable<DpugMethodSpec> methods = const [],
    final Iterable<DpugConstructorSpec> constructors = const [],
    this.extend,
    final Iterable<DpugReferenceSpec> implements = const [],
    final Iterable<DpugReferenceSpec> mixins = const [],
    this.span,
  }) : annotations = BuiltList<DpugAnnotationSpec>.of(annotations),
       stateFields = BuiltList<DpugStateFieldSpec>.of(stateFields),
       methods = BuiltList<DpugMethodSpec>.of(methods),
       constructors = BuiltList<DpugConstructorSpec>.of(constructors),
       implements = BuiltList<DpugReferenceSpec>.of(implements),
       mixins = BuiltList<DpugReferenceSpec>.of(mixins);
  final String name;
  final BuiltList<DpugAnnotationSpec> annotations;
  final BuiltList<DpugStateFieldSpec> stateFields;
  final BuiltList<DpugMethodSpec> methods;
  final BuiltList<DpugConstructorSpec> constructors;
  final DpugReferenceSpec? extend;
  final BuiltList<DpugReferenceSpec> implements;
  final BuiltList<DpugReferenceSpec> mixins;
  final FileSpan? span;

  @override
  R accept<R>(final DpugSpecVisitor<R> visitor, [final R? context]) =>
      visitor.visitClass(this, context);

  @override
  String get code => 'class $name';
}
