import '../visitors/visitor.dart';
import 'expression_spec.dart';

class DpugBinarySpec extends DpugExpressionSpec {
  final String operator;
  final DpugExpressionSpec left;
  final DpugExpressionSpec right;

  const DpugBinarySpec(this.operator, this.left, this.right);

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitBinary(this, context);
}
