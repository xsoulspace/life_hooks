import 'assignment_spec.dart';
import 'binary_spec.dart';
import 'dpug_lambda_spec.dart';
import 'invoke_spec.dart';
import 'list_literal_spec.dart';
import 'reference_expression_spec.dart';
import 'spec.dart';
import 'string_literal_spec.dart';

abstract class DpugExpressionSpec extends DpugSpec {
  const DpugExpressionSpec();

  factory DpugExpressionSpec.reference(String name) =
      DpugReferenceExpressionSpec;
  factory DpugExpressionSpec.string(String value) = DpugStringLiteralSpec;
  factory DpugExpressionSpec.list(List<DpugExpressionSpec> values) =
      DpugListLiteralSpec;
  factory DpugExpressionSpec.lambda(
      List<String> parameters, DpugExpressionSpec body) = DpugLambdaSpec;
  factory DpugExpressionSpec.assignment(
      String target, DpugExpressionSpec value) = DpugAssignmentSpec;
  factory DpugExpressionSpec.binary(
          String operator, DpugExpressionSpec left, DpugExpressionSpec right) =
      DpugBinarySpec;
  factory DpugExpressionSpec.invoke(
      String target, List<DpugExpressionSpec> arguments) = DpugInvokeSpec;
}
