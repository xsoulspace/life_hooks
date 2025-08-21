import '../visitors/visitors.dart';
import 'annotation_spec.dart';
import 'expression_spec.dart';
import 'spec.dart';

class DpugStateFieldSpec extends DpugSpec {
  DpugStateFieldSpec({
    required this.name,
    required this.type,
    required this.annotation,
    this.initializer,
  });
  final String name;
  final String type;
  final DpugAnnotationSpec annotation;
  final DpugExpressionSpec? initializer;

  @override
  R accept<R>(final DpugSpecVisitor<R> visitor, [final R? context]) =>
      visitor.visitStateField(this, context);

  @override
  String get code => '$type $name';
}
