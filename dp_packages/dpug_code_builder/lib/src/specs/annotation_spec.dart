import '../visitors/visitors.dart';
import 'expression_spec.dart';
import 'spec.dart';

class DpugAnnotationSpec extends DpugExpressionSpec implements DpugSpec {
  const DpugAnnotationSpec({required this.name, this.arguments = const []});

  factory DpugAnnotationSpec.listen() =>
      const DpugAnnotationSpec(name: 'listen');

  factory DpugAnnotationSpec.stateful() =>
      const DpugAnnotationSpec(name: 'stateful');

  factory DpugAnnotationSpec.stateless() =>
      const DpugAnnotationSpec(name: 'stateless');

  factory DpugAnnotationSpec.state() => const DpugAnnotationSpec(name: 'state');
  final String name;
  final List<DpugExpressionSpec> arguments;

  @override
  R accept<R>(final DpugSpecVisitor<R> visitor, [final R? context]) =>
      visitor.visitAnnotation(this);

  @override
  String get code => '@$name';
}
