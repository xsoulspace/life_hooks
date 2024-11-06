import '../visitors/visitors.dart';
import 'expression_spec.dart';

class DpugLambdaSpec extends DpugExpressionSpec {
  final List<String> parameters;
  final DpugExpressionSpec body;

  const DpugLambdaSpec(this.parameters, this.body);

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitLambda(this);
}
