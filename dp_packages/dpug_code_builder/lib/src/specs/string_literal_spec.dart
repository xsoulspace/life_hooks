import '../visitors/visitors.dart';
import 'expression_spec.dart';

class DpugStringLiteralSpec extends DpugExpressionSpec {
  const DpugStringLiteralSpec(this.value, {this.raw = false});
  final String value;
  final bool raw;

  @override
  R accept<R>(final DpugSpecVisitor<R> visitor, [final R? context]) =>
      visitor.visitStringLiteral(this, context);
}
