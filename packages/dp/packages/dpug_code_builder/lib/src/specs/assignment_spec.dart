import '../visitors/visitor.dart';
import 'expression_spec.dart';

class DpugAssignmentSpec extends DpugExpressionSpec {
  final String target;
  final DpugExpressionSpec value;

  const DpugAssignmentSpec(this.target, this.value);

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitAssignment(this);
}
