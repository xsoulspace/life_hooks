import '../visitors/visitor.dart';
import 'expression_spec.dart';

class DpugBinarySpec extends DpugExpressionSpec {
  const DpugBinarySpec(this.operator, this.left, this.right);
  final String operator;
  final DpugExpressionSpec left;
  final DpugExpressionSpec right;

  @override
  R accept<R>(final DpugSpecVisitor<R> visitor, [final R? context]) =>
      visitor.visitBinary(this, context);
}
