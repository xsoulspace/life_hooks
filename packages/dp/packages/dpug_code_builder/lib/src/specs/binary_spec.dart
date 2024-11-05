import '../visitors/visitor.dart';
import 'expression_spec.dart';

class DpugBinarySpec extends DpugExpressionSpec {
  final String operator;
  final DpugExpressionSpec left;
  final DpugExpressionSpec right;

  const DpugBinarySpec(this.operator, this.left, this.right);

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitBinary(this);
}
