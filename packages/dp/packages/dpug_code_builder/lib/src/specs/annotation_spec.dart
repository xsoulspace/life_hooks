import '../visitors/visitors.dart';
import 'specs.dart';

class DpugAnnotationSpec extends DpugSpec {
  final String name;
  final List<DpugExpressionSpec> arguments;

  const DpugAnnotationSpec({
    required this.name,
    this.arguments = const [],
  });

  factory DpugAnnotationSpec.stateful() => DpugAnnotationSpec(name: 'stateful');

  factory DpugAnnotationSpec.listen() => DpugAnnotationSpec(name: 'listen');

  factory DpugAnnotationSpec.state() => DpugAnnotationSpec(name: 'state');

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitAnnotation(this);
}
