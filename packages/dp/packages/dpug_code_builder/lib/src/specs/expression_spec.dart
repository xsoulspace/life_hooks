import '../builders/builders.dart';
import '../visitors/visitors.dart';
import 'assignment_spec.dart';
import 'binary_spec.dart';
import 'closure_spec.dart';
import 'invoke_spec.dart';
import 'list_literal_spec.dart';
import 'method_spec.dart';
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
  factory DpugExpressionSpec.string(String value) = DpugStringLiteralSpec;
  factory DpugExpressionSpec.list(List<DpugExpressionSpec> values) =
      DpugListLiteralSpec;
  factory DpugExpressionSpec.closure(DpugMethodSpec method) =
      DpugClosureExpressionSpec;
  factory DpugExpressionSpec.assignment(
      String target, DpugExpressionSpec value) = DpugAssignmentSpec;
  factory DpugExpressionSpec.binary(
          String operator, DpugExpressionSpec left, DpugExpressionSpec right) =
      DpugBinarySpec;
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
