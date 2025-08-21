import '../visitors/visitor.dart';
import 'expression_spec.dart';

class DpugAssignmentSpec extends DpugExpressionSpec {
  const DpugAssignmentSpec(this.target, this.value);
  final String target;
  final DpugExpressionSpec value;

  @override
  R accept<R>(final DpugSpecVisitor<R> visitor, [final R? context]) =>
      visitor.visitAssignment(this, context);
}
