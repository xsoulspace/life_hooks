import '../visitors/visitor.dart';
import 'expression_spec.dart';

class DpugInvokeSpec extends DpugExpressionSpec {
  final String target;
  final List<DpugExpressionSpec> arguments;

  const DpugInvokeSpec(this.target, this.arguments);

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitInvoke(this);
}
