import 'package:built_collection/built_collection.dart';
import 'package:source_span/source_span.dart';

import '../visitors/visitor.dart';
import 'annotation_spec.dart';
import 'constructor_spec.dart';
import 'method_spec.dart';
import 'reference_spec.dart';
import 'spec.dart';
import 'state_field_spec.dart';

class DpugClassSpec extends DpugSpec {
  final String name;
  final BuiltList<DpugAnnotationSpec> annotations;
  final BuiltList<DpugStateFieldSpec> stateFields;
  final BuiltList<DpugMethodSpec> methods;
  final BuiltList<DpugConstructorSpec> constructors;
  final DpugReferenceSpec? extend;
  final BuiltList<DpugReferenceSpec> implements;
  final BuiltList<DpugReferenceSpec> mixins;
  final FileSpan? span;

  DpugClassSpec({
    required this.name,
    Iterable<DpugAnnotationSpec> annotations = const [],
    Iterable<DpugStateFieldSpec> stateFields = const [],
    Iterable<DpugMethodSpec> methods = const [],
    Iterable<DpugConstructorSpec> constructors = const [],
    this.extend,
    Iterable<DpugReferenceSpec> implements = const [],
    Iterable<DpugReferenceSpec> mixins = const [],
    this.span,
  })  : annotations = BuiltList<DpugAnnotationSpec>.of(annotations),
        stateFields = BuiltList<DpugStateFieldSpec>.of(stateFields),
        methods = BuiltList<DpugMethodSpec>.of(methods),
        constructors = BuiltList<DpugConstructorSpec>.of(constructors),
        implements = BuiltList<DpugReferenceSpec>.of(implements),
        mixins = BuiltList<DpugReferenceSpec>.of(mixins);

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitClass(this, context);
}
