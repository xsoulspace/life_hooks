import '../visitors/visitor.dart';
import 'expression_spec.dart';
import 'reference_spec.dart';

class DpugInvokeSpec extends DpugExpressionSpec {
  final DpugExpressionSpec target;
  final List<DpugExpressionSpec> positionedArguments;
  final Map<String, DpugExpressionSpec> namedArguments;
  final List<DpugReferenceSpec> typeArguments;
  final String? name;
  final bool isConst;
  const DpugInvokeSpec({
    required this.target,
    this.positionedArguments = const [],
    this.namedArguments = const {},
    this.typeArguments = const [],
    this.isConst = false,
    this.name,
  });

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitInvoke(this, context);
}
