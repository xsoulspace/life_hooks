import '../visitors/visitors.dart';
import 'expression_spec.dart';
import 'method_spec.dart';
import 'parameter_spec.dart';

class DpugClosureExpressionSpec extends DpugExpressionSpec {
  final DpugMethodSpec method;

  const DpugClosureExpressionSpec(this.method);

  factory DpugClosureExpressionSpec.fromParams(
    List<String> params,
    DpugExpressionSpec body,
  ) {
    return DpugClosureExpressionSpec(
      DpugMethodSpec(
        name: '',
        returnType: 'dynamic',
        parameters:
            params.map((p) => DpugParameterSpec(name: p, type: null)).toList(),
        body: body,
        isGetter: false,
      ),
    );
  }

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitClosureExpression(this, context);
}

// legacy alias removed; use DpugClosureExpressionSpec.fromParams instead
