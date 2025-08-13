import '../builders/builders.dart';
import '../visitors/visitors.dart';
import 'expression_spec.dart';

class DpugWidgetExpressionSpec extends DpugExpressionSpec {
  final DpugWidgetBuilder builder;

  const DpugWidgetExpressionSpec(this.builder);

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      builder.accept(visitor, context);
}
