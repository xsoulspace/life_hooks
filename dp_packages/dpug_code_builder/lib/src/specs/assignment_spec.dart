import '../visitors/visitor.dart';
import 'expression_spec.dart';

class DpugAssignmentSpec extends DpugExpressionSpec {
  final String target;
  final DpugExpressionSpec value;

  const DpugAssignmentSpec(this.target, this.value);

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitAssignment(this, context);
}
