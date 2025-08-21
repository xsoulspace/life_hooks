import '../builders/builders.dart';
import '../visitors/visitors.dart';
import 'expression_spec.dart';

class DpugWidgetExpressionSpec extends DpugExpressionSpec {
  const DpugWidgetExpressionSpec(this.builder);
  final DpugWidgetBuilder builder;

  @override
  R accept<R>(final DpugSpecVisitor<R> visitor, [final R? context]) =>
      builder.accept(visitor, context);
}
