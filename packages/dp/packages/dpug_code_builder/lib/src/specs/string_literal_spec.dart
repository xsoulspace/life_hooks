import '../visitors/visitors.dart';
import 'expression_spec.dart';

class DpugStringLiteralSpec extends DpugExpressionSpec {
  final String value;
  const DpugStringLiteralSpec(this.value);

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitStringLiteral(this);
}
