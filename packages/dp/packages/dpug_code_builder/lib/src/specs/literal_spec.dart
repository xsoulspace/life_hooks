import '../visitors/visitor.dart';
import 'expression_spec.dart';

class DpugLiteralSpec extends DpugExpressionSpec {
  final Object value;

  const DpugLiteralSpec(this.value);

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitLiteral(this, context);
}
