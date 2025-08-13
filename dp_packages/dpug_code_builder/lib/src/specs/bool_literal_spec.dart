import '../visitors/visitors.dart';
import 'expression_spec.dart';

class DpugBoolLiteralSpec extends DpugExpressionSpec {
  final bool value;
  final bool raw;
  const DpugBoolLiteralSpec(this.value, {this.raw = false});

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitBoolLiteral(this, context);
}
