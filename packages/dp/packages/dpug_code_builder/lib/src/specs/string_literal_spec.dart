import '../visitors/visitors.dart';
import 'expression_spec.dart';

class DpugStringLiteralSpec extends DpugExpressionSpec {
  final String value;
  final bool raw;
  const DpugStringLiteralSpec(this.value, {this.raw = false});

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitStringLiteral(this, context);
}
