import '../specs/specs.dart';

abstract class DpugSpecVisitor<R> {
  R visitClass(final DpugClassSpec spec, [final R? context]);
  R visitConstructor(final DpugConstructorSpec spec, [final R? context]);
  R visitMethod(final DpugMethodSpec spec, [final R? context]);
  R visitParameter(final DpugParameterSpec spec, [final R? context]);
  R visitReference(final DpugReferenceSpec spec, [final R? context]);
  R visitReferenceExpression(
    final DpugReferenceExpressionSpec spec, [
    final R? context,
  ]);
  R visitWidget(final DpugWidgetSpec spec, [final R? context]);
  R visitAnnotation(final DpugAnnotationSpec spec, [final R? context]);
  R visitBoolLiteral(final DpugBoolLiteralSpec spec, [final R? context]);
  R visitNumLiteral(final DpugNumLiteralSpec spec, [final R? context]);
  R visitCode(final DpugCodeSpec spec, [final R? context]);
  R visitLiteral(final DpugLiteralSpec spec, [final R? context]);
  R visitBinary(final DpugBinarySpec spec, [final R? context]);
  R visitInvoke(final DpugInvokeSpec spec, [final R? context]);
  R visitListLiteral(final DpugListLiteralSpec spec, [final R? context]);
  R visitStringLiteral(final DpugStringLiteralSpec spec, [final R? context]);
  R visitClosureExpression(
    final DpugClosureExpressionSpec spec, [
    final R? context,
  ]);
  R visitExpression(final DpugExpressionSpec spec, [final R? context]);
  R visitAssignment(final DpugAssignmentSpec spec, [final R? context]);
  R visitStateField(final DpugStateFieldSpec spec, [final R? context]);
}
