import '../visitors/visitors.dart';
import 'specs.dart';

class DpugWidgetSpec extends DpugSpec {
  final String name;
  final List<DpugWidgetSpec> children;
  final Map<String, DpugExpressionSpec> properties;

  const DpugWidgetSpec({
    required this.name,
    this.children = const [],
    this.properties = const {},
  });

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitWidget(this);
}
