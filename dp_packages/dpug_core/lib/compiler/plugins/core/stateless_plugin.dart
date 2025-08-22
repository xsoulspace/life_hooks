import 'package:code_builder/code_builder.dart' as cb;

import '../../../dpug_core.dart';
import '../annotation_plugins.dart';

/// {@template stateless_plugin}
/// Core plugin that handles @stateless annotation for generating StatelessWidget classes.
///
/// This plugin ensures classes annotated with @stateless generate proper StatelessWidget
/// implementations and validates that no state fields are present.
///
/// Features:
/// - Validates no state fields are present
/// - Generates StatelessWidget implementations
/// - Provides architectural safety for display-only widgets
/// - Prevents common mistakes with state management
/// {@endtemplate}
class StatelessPlugin implements AnnotationPlugin {
  /// {@macro stateless_plugin}
  const StatelessPlugin();

  @override
  String get annotationName => 'stateless';

  @override
  bool canHandle(final String annotationName) =>
      annotationName == this.annotationName;

  @override
  void processClassAnnotation({
    required final String annotationName,
    required final ClassNode classNode,
    final DpugConverter? converter,
  }) {
    print('Processing @stateless annotation for class ${classNode.name}');

    // Validate that this class doesn't have state fields
    if (classNode.stateVariables.isNotEmpty) {
      throw StateError(
        '@stateless classes cannot have state fields. Use @stateful instead.',
      );
    }
  }

  @override
  void processFieldAnnotation({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    final DpugConverter? converter,
  }) {
    throw StateError('@stateless can only be applied to classes, not fields');
  }

  @override
  cb.Spec? generateClassCode({
    required final String annotationName,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // Return a special marker that indicates this should generate stateless code
    return const cb.Code('__STATELESS_WIDGET__');
  }

  @override
  cb.Spec? generateFieldCode({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // @stateless doesn't generate field code
    return null;
  }
}
