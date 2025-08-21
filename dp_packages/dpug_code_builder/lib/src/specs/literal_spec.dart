import '../visitors/visitor.dart';
import 'expression_spec.dart';

class DpugLiteralSpec extends DpugExpressionSpec {
  const DpugLiteralSpec(this.value);
  final Object value;

  @override
  R accept<R>(final DpugSpecVisitor<R> visitor, [final R? context]) =>
      visitor.visitLiteral(this, context);
}
