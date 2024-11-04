import '../specs/specs.dart';

abstract class DpugSpecVisitor<T> {
  T visitClass(DpugClassSpec spec);
  T visitStateField(DpugStateFieldSpec spec);
  T visitMethod(DpugMethodSpec spec);
  T visitParameter(DpugParameterSpec spec);
  T visitWidget(DpugWidgetSpec spec);
  T visitAnnotation(DpugAnnotationSpec spec);
  T visitReference(DpugReferenceSpec spec);
  T visitListLiteral(DpugListLiteralSpec spec);
  T visitStringLiteral(DpugStringLiteralSpec spec);
  T visitLambda(DpugLambdaSpec spec);
  T visitAssignment(DpugAssignmentSpec spec);
}
