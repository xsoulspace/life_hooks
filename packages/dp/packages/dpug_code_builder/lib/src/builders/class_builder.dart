import 'package:built_collection/built_collection.dart';
import 'package:dpug/src/visitors/visitor.dart';
import 'package:source_span/source_span.dart';

import '../specs/specs.dart';

class DpugClassBuilder implements DpugSpec {
  String? _name;
  final ListBuilder<DpugAnnotationSpec> _annotations =
      ListBuilder<DpugAnnotationSpec>();
  final ListBuilder<DpugStateFieldSpec> _stateFields =
      ListBuilder<DpugStateFieldSpec>();
  final ListBuilder<DpugMethodSpec> _methods = ListBuilder<DpugMethodSpec>();
  FileSpan? span;

  DpugClassBuilder name(String name) {
    _name = name;
    return this;
  }

  DpugClassBuilder annotation(DpugAnnotationSpec annotation) {
    _annotations.add(annotation);
    return this;
  }

  DpugClassBuilder stateField(DpugStateFieldSpec field) {
    _stateFields.add(field);
    return this;
  }

  DpugClassBuilder method(DpugMethodSpec method) {
    _methods.add(method);
    return this;
  }

  DpugClassBuilder buildGetter({
    required String name,
    required String returnType,
    required DpugSpec body,
  }) {
    method(DpugMethodSpec.getter(
      name: name,
      returnType: returnType,
      body: body,
    ));
    return this;
  }

  DpugClassBuilder listenField({
    required String name,
    required String type,
    DpugExpressionSpec? initializer,
  }) {
    stateField(DpugStateFieldSpec(
      name: name,
      type: type,
      annotation: DpugAnnotationSpec.listen(),
      initializer: initializer,
    ));
    return this;
  }

  DpugClassBuilder buildMethod({
    required DpugSpec body,
  }) {
    method(DpugMethodSpec.getter(
      name: 'build',
      returnType: 'Widget',
      body: body,
    ));
    return this;
  }

  DpugClassSpec build() {
    if (_name == null) {
      throw StateError('Class name must be set');
    }

    return DpugClassSpec(
      name: _name!,
      annotations: _annotations.build(),
      stateFields: _stateFields.build(),
      methods: _methods.build(),
      span: span ?? SourceFile.fromString('').span(0),
    );
  }

  @override
  R accept<R>(DpugSpecVisitor<R> visitor, [R? context]) =>
      visitor.visitClass(build());
}
