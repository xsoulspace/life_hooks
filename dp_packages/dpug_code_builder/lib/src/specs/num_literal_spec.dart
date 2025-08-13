import '../visitors/visitors.dart';
import 'expression_spec.dart';

class DpugNumLiteralSpec extends DpugExpressionSpec {
  final num value;
  final bool raw;
  const DpugNumLiteralSpec(this.value, {this.raw = false});

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitNumLiteral(this, context);
}
