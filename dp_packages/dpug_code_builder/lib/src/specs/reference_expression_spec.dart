import '../visitors/visitors.dart';
import 'expression_spec.dart';

// For reference expressions in code
class DpugReferenceExpressionSpec extends DpugExpressionSpec {
  const DpugReferenceExpressionSpec(this.name);
  final String name;

  @override
  R accept<R>(final DpugSpecVisitor<R> visitor, [final R? context]) =>
      visitor.visitReferenceExpression(this, context);
}
