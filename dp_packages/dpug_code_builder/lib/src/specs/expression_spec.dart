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

  factory DpugExpressionSpec.reference(String name) =
      DpugReferenceExpressionSpec;
  factory DpugExpressionSpec.widget(DpugWidgetBuilder builder) =
      DpugWidgetExpressionSpec;
  factory DpugExpressionSpec.boolLiteral(bool value) = DpugBoolLiteralSpec;
  factory DpugExpressionSpec.numLiteral(num value) = DpugNumLiteralSpec;
  factory DpugExpressionSpec.string(String value) = DpugStringLiteralSpec;
  factory DpugExpressionSpec.list(List<DpugExpressionSpec> values) =
      DpugListLiteralSpec;
  // Primary convenience factory used across tests: closure(params, body)
  factory DpugExpressionSpec.closure(
    List<String> params,
    DpugExpressionSpec body,
  ) = DpugClosureExpressionSpec.fromParams;

  // Secondary factory if a prebuilt method is available
  factory DpugExpressionSpec.closureFromMethod(DpugMethodSpec method) =
      DpugClosureExpressionSpec;
  factory DpugExpressionSpec.assignment(
    String target,
    DpugExpressionSpec value,
  ) = DpugAssignmentSpec;
  factory DpugExpressionSpec.binary(
    String operator,
    DpugExpressionSpec left,
    DpugExpressionSpec right,
  ) = DpugBinarySpec;
  factory DpugExpressionSpec.invoke({
    required DpugExpressionSpec target,
    List<DpugExpressionSpec> positionedArguments,
    Map<String, DpugExpressionSpec> namedArguments,
    List<DpugReferenceSpec> typeArguments,
    String? name,
    bool isConst,
  }) = DpugInvokeSpec;

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitExpression(this, context);
}
