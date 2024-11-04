import 'package:built_collection/built_collection.dart';
import 'package:source_span/source_span.dart';

import '../visitors/visitors.dart';
import 'annotation_spec.dart';
import 'expression_spec.dart';
import 'method_spec.dart';

export 'annotation_spec.dart';
export 'expression_spec.dart';
export 'method_spec.dart';
export 'widget_spec.dart';

abstract class DpugSpec {
  const DpugSpec();

  T accept<T>(DpugSpecVisitor<T> visitor);
}

class DpugClassSpec extends DpugSpec {
  final String name;
  final BuiltList<DpugAnnotationSpec> annotations;
  final BuiltList<DpugStateFieldSpec> stateFields;
  final BuiltList<DpugMethodSpec> methods;
  final FileSpan span;

  factory DpugClassSpec({
    required String name,
    Iterable<DpugAnnotationSpec> annotations = const [],
    Iterable<DpugStateFieldSpec> stateFields = const [],
    Iterable<DpugMethodSpec> methods = const [],
    required FileSpan span,
  }) {
    return DpugClassSpec._(
      name: name,
      annotations: BuiltList<DpugAnnotationSpec>.of(annotations),
      stateFields: BuiltList<DpugStateFieldSpec>.of(stateFields),
      methods: BuiltList<DpugMethodSpec>.of(methods),
      span: span,
    );
  }

  const DpugClassSpec._({
    required this.name,
    required this.annotations,
    required this.stateFields,
    required this.methods,
    required this.span,
  });

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitClass(this);
}

class DpugStateFieldSpec extends DpugSpec {
  final String name;
  final String type;
  final DpugAnnotationSpec annotation;
  final DpugExpressionSpec? initializer;

  const DpugStateFieldSpec({
    required this.name,
    required this.type,
    required this.annotation,
    this.initializer,
  });

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitStateField(this);
}

// Add other specs... 