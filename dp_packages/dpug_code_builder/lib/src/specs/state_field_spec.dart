import '../visitors/visitors.dart';
import 'annotation_spec.dart';
import 'expression_spec.dart';
import 'spec.dart';

class DpugStateFieldSpec extends DpugSpec {
  final String name;
  final String type;
  final DpugAnnotationSpec annotation;
  final DpugExpressionSpec? initializer;

  DpugStateFieldSpec({
    required this.name,
    required this.type,
    required this.annotation,
    this.initializer,
  });

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitStateField(this, context);
}
