import '../visitors/visitor.dart';
import 'expression_spec.dart';
import 'spec.dart';

class DpugParameterSpec extends DpugSpec {
  final String name;
  final String type;
  final bool isNamed;
  final bool isRequired;
  final DpugExpressionSpec? defaultValue;

  const DpugParameterSpec({
    required this.name,
    required this.type,
    this.isNamed = false,
    this.isRequired = false,
    this.defaultValue,
  });

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitParameter(this, context);
}
