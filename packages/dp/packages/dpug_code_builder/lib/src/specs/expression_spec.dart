import '../builders/builders.dart';
import '../visitors/visitors.dart';
import 'specs.dart';

abstract class DpugExpressionSpec extends DpugSpec {
  const DpugExpressionSpec();

  factory DpugExpressionSpec.reference(String name) = DpugReferenceSpec;

  factory DpugExpressionSpec.listLiteral(List<DpugExpressionSpec> values) =
      DpugListLiteralSpec;

  factory DpugExpressionSpec.stringLiteral(String value) =
      DpugStringLiteralSpec;

  factory DpugExpressionSpec.lambda(
      List<String> parameters, DpugExpressionSpec body) = DpugLambdaSpec;

  factory DpugExpressionSpec.assignment(
      String target, DpugExpressionSpec value) = DpugAssignmentSpec;

  factory DpugExpressionSpec.widget(DpugWidgetBuilder builder) =
      DpugWidgetExpressionSpec;
}

class DpugReferenceSpec extends DpugExpressionSpec {
  final String name;
  const DpugReferenceSpec(this.name);

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitReference(this);
}

class DpugListLiteralSpec extends DpugExpressionSpec {
  final List<DpugExpressionSpec> values;
  const DpugListLiteralSpec(this.values);

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitListLiteral(this);
}

class DpugStringLiteralSpec extends DpugExpressionSpec {
  final String value;
  const DpugStringLiteralSpec(this.value);

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitStringLiteral(this);
}

class DpugLambdaSpec extends DpugExpressionSpec {
  final List<String> parameters;
  final DpugExpressionSpec body;

  const DpugLambdaSpec(this.parameters, this.body);

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitLambda(this);
}

class DpugAssignmentSpec extends DpugExpressionSpec {
  final String target;
  final DpugExpressionSpec value;

  const DpugAssignmentSpec(this.target, this.value);

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => visitor.visitAssignment(this);
}

class DpugWidgetExpressionSpec extends DpugExpressionSpec {
  final DpugWidgetBuilder builder;

  const DpugWidgetExpressionSpec(this.builder);

  @override
  T accept<T>(DpugSpecVisitor<T> visitor) => builder.accept(visitor);
}
