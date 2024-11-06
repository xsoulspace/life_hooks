import '../builders/builders.dart';
import '../visitors/visitors.dart';
import 'expression_spec.dart';

class DpugWidgetExpressionSpec extends DpugExpressionSpec {
  final DpugWidgetBuilder builder;

  const DpugWidgetExpressionSpec(this.builder);

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => builder.accept(visitor);
}
