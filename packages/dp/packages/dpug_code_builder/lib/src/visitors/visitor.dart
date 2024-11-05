import '../specs/specs.dart';

abstract class DpugSpecVisitor<T> {
  T visitClass(DpugClassSpec spec);
  T visitConstructor(DpugConstructorSpec spec);
  T visitMethod(DpugMethodSpec spec);
  T visitParameter(DpugParameterSpec spec);
  T visitReference(DpugReferenceSpec spec);
  T visitReferenceExpression(DpugReferenceExpressionSpec spec);
  T visitWidget(DpugWidgetSpec spec);
  T visitAnnotation(DpugAnnotationSpec spec);
  T visitLiteral(DpugLiteralSpec spec);
  T visitBinary(DpugBinarySpec spec);
  T visitInvoke(DpugInvokeSpec spec);
  T visitListLiteral(DpugListLiteralSpec spec);
  T visitStringLiteral(DpugStringLiteralSpec spec);
  T visitLambda(DpugLambdaSpec spec);
  T visitAssignment(DpugAssignmentSpec spec);
  T visitStateField(DpugStateFieldSpec spec);
}
