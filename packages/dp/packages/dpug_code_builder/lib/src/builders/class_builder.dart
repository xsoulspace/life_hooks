import 'package:source_span/source_span.dart';

import '../specs/specs.dart';

class DpugClassBuilder {
  String? _name;
  final List<DpugAnnotationSpec> _annotations = [];
  final List<DpugStateFieldSpec> _stateFields = [];
  final List<DpugMethodSpec> _methods = [];
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

  DpugClassSpec build() {
    if (_name == null) {
      throw StateError('Class name must be set');
    }

    // Create a default FileSpan if none is provided
    final defaultSpan = SourceFile.fromString('').span(0);

    return DpugClassSpec(
      name: _name!,
      annotations: _annotations,
      stateFields: _stateFields,
      methods: _methods,
      span: span ?? defaultSpan,
    );
  }
}
