import '../visitors/visitors.dart';
import 'expression_spec.dart';

// For reference expressions in code
class DpugReferenceExpressionSpec extends DpugExpressionSpec {
  final String name;

  const DpugReferenceExpressionSpec(this.name);

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitReferenceExpression(this, context);
}
