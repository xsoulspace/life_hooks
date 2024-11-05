import '../visitors/visitors.dart';
import 'specs.dart';

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
