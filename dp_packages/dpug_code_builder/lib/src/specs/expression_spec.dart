import '../builders/builders.dart';
import '../visitors/visitors.dart';
import 'assignment_spec.dart';
import 'binary_spec.dart';
import 'bool_literal_spec.dart';
import 'closure_spec.dart';
import 'invoke_spec.dart';
import 'list_literal_spec.dart';
import 'method_spec.dart';
import 'num_literal_spec.dart';
import 'reference_expression_spec.dart';
import 'reference_spec.dart';
import 'spec.dart';
import 'string_literal_spec.dart';
import 'widget_expression_spec.dart';

class DpugExpressionSpec implements DpugSpec {
  const DpugExpressionSpec();

  factory DpugExpressionSpec.reference(final String name) =
      DpugReferenceExpressionSpec;
  factory DpugExpressionSpec.widget(final DpugWidgetBuilder builder) =
      DpugWidgetExpressionSpec;
  factory DpugExpressionSpec.boolLiteral(final bool value) =
      DpugBoolLiteralSpec;
  factory DpugExpressionSpec.numLiteral(final num value) = DpugNumLiteralSpec;
  factory DpugExpressionSpec.string(final String value) = DpugStringLiteralSpec;
  factory DpugExpressionSpec.list(final List<DpugExpressionSpec> values) =
      DpugListLiteralSpec;
  // Primary convenience factory used across tests: closure(params, body)
  factory DpugExpressionSpec.closure(
    final List<String> params,
    final DpugExpressionSpec body,
  ) = DpugClosureExpressionSpec.fromParams;

  // Secondary factory if a prebuilt method is available
  factory DpugExpressionSpec.closureFromMethod(final DpugMethodSpec method) =
      DpugClosureExpressionSpec;
  factory DpugExpressionSpec.assignment(
    final String target,
    final DpugExpressionSpec value,
  ) = DpugAssignmentSpec;
  factory DpugExpressionSpec.binary(
    final String operator,
    final DpugExpressionSpec left,
    final DpugExpressionSpec right,
  ) = DpugBinarySpec;
  factory DpugExpressionSpec.invoke({
    required final DpugExpressionSpec target,
    final List<DpugExpressionSpec> positionedArguments,
    final Map<String, DpugExpressionSpec> namedArguments,
    final List<DpugReferenceSpec> typeArguments,
    final String? name,
    final bool isConst,
  }) = DpugInvokeSpec;

  @override
  R accept<R>(final DpugSpecVisitor<R> visitor, [final R? context]) =>
      visitor.visitExpression(this, context);
}
