import '../visitors/visitors.dart';
import 'expression_spec.dart';

class DpugNumLiteralSpec extends DpugExpressionSpec {
  const DpugNumLiteralSpec(this.value, {this.raw = false});
  final num value;
  final bool raw;

  @override
  R accept<R>(final DpugSpecVisitor<R> visitor, [final R? context]) =>
      visitor.visitNumLiteral(this, context);
}
