import '../specs/specs.dart';

abstract class DpugSpecVisitor<R> {
  R visitClass(DpugClassSpec spec, [R? context]);
  R visitConstructor(DpugConstructorSpec spec, [R? context]);
  R visitMethod(DpugMethodSpec spec, [R? context]);
  R visitParameter(DpugParameterSpec spec, [R? context]);
  R visitReference(DpugReferenceSpec spec, [R? context]);
  R visitReferenceExpression(DpugReferenceExpressionSpec spec, [R? context]);
  R visitWidget(DpugWidgetSpec spec, [R? context]);
  R visitAnnotation(DpugAnnotationSpec spec);
  R visitLiteral(DpugLiteralSpec spec, [R? context]);
  R visitBinary(DpugBinarySpec spec, [R? context]);
  R visitInvoke(DpugInvokeSpec spec, [R? context]);
  R visitListLiteral(DpugListLiteralSpec spec, [R? context]);
  R visitStringLiteral(DpugStringLiteralSpec spec, [R? context]);
  R visitClosureExpression(DpugClosureExpressionSpec spec, [R? context]);
  R visitAssignment(DpugAssignmentSpec spec, [R? context]);
  R visitStateField(DpugStateFieldSpec spec, [R? context]);
}
