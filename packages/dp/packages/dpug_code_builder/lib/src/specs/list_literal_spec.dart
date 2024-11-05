import '../visitors/visitors.dart';
import 'expression_spec.dart';

class DpugListLiteralSpec extends DpugExpressionSpec {
  final List<DpugExpressionSpec> values;
  const DpugListLiteralSpec(this.values);

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitListLiteral(this);
}
