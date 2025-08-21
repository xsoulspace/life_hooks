import '../visitors/visitors.dart';
import 'expression_spec.dart';
import 'method_spec.dart';
import 'parameter_spec.dart';

class DpugClosureExpressionSpec extends DpugExpressionSpec {
  const DpugClosureExpressionSpec(this.method);

  factory DpugClosureExpressionSpec.fromParams(
    final List<String> params,
    final DpugExpressionSpec body,
  ) => DpugClosureExpressionSpec(
    DpugMethodSpec(
      name: '',
      returnType: 'dynamic',
      parameters: params
          .map((final p) => DpugParameterSpec(name: p, type: null))
          .toList(),
      body: body,
    ),
  );
  final DpugMethodSpec method;

  @override
  R accept<R>(final DpugSpecVisitor<R> visitor, [final R? context]) =>
      visitor.visitClosureExpression(this, context);
}

// legacy alias removed; use DpugClosureExpressionSpec.fromParams instead
