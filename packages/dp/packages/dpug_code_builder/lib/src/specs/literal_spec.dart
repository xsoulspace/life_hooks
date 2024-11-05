import '../visitors/visitor.dart';
import 'expression_spec.dart';

class DpugLiteralSpec extends DpugExpressionSpec {
  final Object value;

  const DpugLiteralSpec(this.value);

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitLiteral(this);
}
