import '../visitors/visitors.dart';
import 'expression_spec.dart';

class DpugListLiteralSpec extends DpugExpressionSpec {
  final List<DpugExpressionSpec> values;
  const DpugListLiteralSpec(this.values);

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitListLiteral(this, context);
}
