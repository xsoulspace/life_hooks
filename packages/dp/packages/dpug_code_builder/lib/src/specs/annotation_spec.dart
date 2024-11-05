import '../visitors/visitor.dart';
import 'expression_spec.dart';
import 'spec.dart';

class DpugAnnotationSpec extends DpugSpec {
  final String name;
  final List<DpugExpressionSpec> arguments;

  const DpugAnnotationSpec({
    required this.name,
    this.arguments = const [],
  });

  factory DpugAnnotationSpec.stateful() =>
      const DpugAnnotationSpec(name: 'stateful');

  factory DpugAnnotationSpec.state() => const DpugAnnotationSpec(name: 'state');

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitAnnotation(this);
}
