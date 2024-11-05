import '../visitors/visitors.dart';
import 'expression_spec.dart';

// For reference expressions in code
class DpugReferenceExpressionSpec extends DpugExpressionSpec {
  final String name;

  const DpugReferenceExpressionSpec(this.name);

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) =>
      visitor.visitReferenceExpression(this);
}
