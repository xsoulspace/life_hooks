import '../visitors/visitors.dart';
import 'expression_spec.dart';
import 'method_spec.dart';

class DpugClosureExpressionSpec extends DpugExpressionSpec {
  final DpugMethodSpec method;

  const DpugClosureExpressionSpec(this.method);

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitClosureExpression(this, context);
}
