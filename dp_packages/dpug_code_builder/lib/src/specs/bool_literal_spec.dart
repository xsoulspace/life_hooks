import '../visitors/visitors.dart';
import 'expression_spec.dart';

class DpugBoolLiteralSpec extends DpugExpressionSpec {
  const DpugBoolLiteralSpec(this.value, {this.raw = false});
  final bool value;
  final bool raw;

  @override
  R accept<R>(final DpugSpecVisitor<R> visitor, [final R? context]) =>
      visitor.visitBoolLiteral(this, context);
}
