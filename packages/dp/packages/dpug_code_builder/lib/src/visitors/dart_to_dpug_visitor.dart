import '../specs/specs.dart';
// !DO NOT REMOVE IMPORT!
import 'dart_imports.dart';

class DartToDpugSpecVisitor
    implements
        SpecVisitor<DpugSpec?>,
        ExpressionVisitor<DpugSpec?>,
        CodeVisitor<DpugSpec?> {
  const DartToDpugSpecVisitor();

  @override
  DpugSpec? visitClass(Class spec, [DpugSpec? context]) {
    // Convert class with all its members
    final annotations = spec.annotations
        .map((a) => DpugAnnotationSpec(name: a.toString()))
        .toList();

    final fields = spec.fields
        .map((f) => visitField(f, context))
        .whereType<DpugStateFieldSpec>()
        .toList();

    final methods = spec.methods
        .map((m) => visitMethod(m, context))
        .whereType<DpugMethodSpec>()
        .toList();

    return DpugClassSpec(
      name: spec.name,
      annotations: annotations,
      stateFields: fields,
      methods: methods,
    );
  }

  @override
  DpugSpec? visitField(Field spec, [DpugSpec? context]) {
    if (spec.type != null) {
      return DpugStateFieldSpec(
        name: spec.name,
        type: spec.type.toString(),
        annotation: DpugAnnotationSpec.state(),
        initializer: spec.assignment != null
            ? DpugReferenceSpec(spec.assignment.toString())
            : null,
      );
    }
    return null;
  }

  @override
  DpugSpec? visitMethod(Method spec, [DpugSpec? context]) {
    return DpugMethodSpec(
      name: spec.name,
      returnType: spec.returns?.toString() ?? 'dynamic',
      parameters: spec.requiredParameters
          .map((p) => DpugParameterSpec(
                name: p.name,
                type: p.type?.toString() ?? 'dynamic',
                isRequired: true,
              ))
          .toList(),
      body: DpugReferenceSpec(spec.body?.toString() ?? ''),
      isGetter: spec.type == MethodType.getter,
    );
  }

  // Implement other required SpecVisitor methods
  @override
  DpugSpec? visitDirective(Directive spec, [DpugSpec? context]) => null;

  @override
  DpugSpec? visitEnum(Enum spec, [DpugSpec? context]) => null;

  @override
  DpugSpec? visitConstructor(Constructor spec, String clazz,
          [DpugSpec? context]) =>
      null;

  @override
  DpugSpec? visitExtension(Extension spec, [DpugSpec? context]) => null;

  @override
  DpugSpec? visitExtensionType(ExtensionType spec, [DpugSpec? context]) => null;

  @override
  DpugSpec? visitFunctionType(FunctionType spec, [DpugSpec? context]) => null;

  @override
  DpugSpec? visitLibrary(Library spec, [DpugSpec? context]) => null;

  @override
  DpugSpec? visitMixin(Mixin spec, [DpugSpec? context]) => null;

  @override
  DpugSpec? visitRecordType(RecordType spec, [DpugSpec? context]) => null;

  @override
  DpugSpec? visitReference(Reference spec, [DpugSpec? context]) {
    return DpugReferenceSpec(spec.symbol ?? '');
  }

  @override
  DpugSpec? visitSpec(Spec spec, [DpugSpec? context]) {
    return spec.accept(this, context);
  }

  @override
  DpugSpec? visitType(TypeReference spec, [DpugSpec? context]) => null;

  @override
  DpugSpec? visitTypeParameters(Iterable<Reference> specs,
          [DpugSpec? context]) =>
      null;

  @override
  DpugSpec? visitTypeDef(TypeDef spec, [DpugSpec? context]) => null;
}
