import '../visitors/visitors.dart';
import 'expression_spec.dart';
import 'spec.dart';

class DpugAnnotationSpec extends DpugExpressionSpec implements DpugSpec {
  final String name;
  final List<DpugExpressionSpec> arguments;

  const DpugAnnotationSpec({
    required this.name,
    this.arguments = const [],
  });

  factory DpugAnnotationSpec.listen() =>
      const DpugAnnotationSpec(name: 'listen');

  factory DpugAnnotationSpec.stateful() =>
      const DpugAnnotationSpec(name: 'stateful');

  factory DpugAnnotationSpec.state() => const DpugAnnotationSpec(name: 'state');

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitAnnotation(this);
}
