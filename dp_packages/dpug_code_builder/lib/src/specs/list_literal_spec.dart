import '../visitors/visitors.dart';
import 'expression_spec.dart';

class DpugListLiteralSpec extends DpugExpressionSpec {
  const DpugListLiteralSpec(this.values);
  final List<DpugExpressionSpec> values;

  @override
  R accept<R>(final DpugSpecVisitor<R> visitor, [final R? context]) =>
      visitor.visitListLiteral(this, context);
}
