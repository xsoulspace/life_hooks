import '../visitors/visitor.dart';
import 'expression_spec.dart';
import 'reference_spec.dart';
import 'spec.dart';

class DpugParameterSpec extends DpugSpec {
  DpugParameterSpec({
    required this.name,
    required this.type,
    this.isNamed = false,
    this.isRequired = false,
    this.defaultValue,
  });
  final String name;
  final DpugReferenceSpec? type;
  final bool isNamed;
  final bool isRequired;
  final DpugExpressionSpec? defaultValue;

  @override
  R accept<R>(final DpugSpecVisitor<R> visitor, [final R? context]) =>
      visitor.visitParameter(this, context);
}
