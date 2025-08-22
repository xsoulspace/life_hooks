import 'package:code_builder/code_builder.dart' as cb;

import '../../../dpug_core.dart';
import '../annotation_plugins.dart';

/// {@template stateful_plugin}
/// Core plugin that handles @stateful annotation for generating StatefulWidget classes.
///
/// This plugin transforms classes annotated with @stateful into proper StatefulWidget
/// implementations with automatic state class generation.
///
/// Features:
/// - Converts class fields to state variables
/// - Generates StatefulWidget and State classes
/// - Handles constructor parameters properly
/// - Integrates with other plugins like @changeNotifier
/// {@endtemplate}
class StatefulPlugin implements AnnotationPlugin {
  /// {@macro stateful_plugin}
  const StatefulPlugin();

  @override
  String get annotationName => 'stateful';

  @override
  bool canHandle(final String annotationName) =>
      annotationName == this.annotationName;

  @override
  void processClassAnnotation({
    required final String annotationName,
    required final ClassNode classNode,
    final DpugConverter? converter,
  }) {
    // Validate that this class can be stateful
    // Additional validation logic can be added here
    print('Processing @stateful annotation for class ${classNode.name}');
  }

  @override
  void processFieldAnnotation({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    final DpugConverter? converter,
  }) {
    throw StateError('@stateful can only be applied to classes, not fields');
  }

  @override
  cb.Spec? generateClassCode({
    required final String annotationName,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // This will be handled by the existing code generation logic
    // Return a marker to indicate this should generate stateful code
    return const cb.Code('__STATEFUL_WIDGET__');
  }

  @override
  cb.Spec? generateFieldCode({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // @stateful doesn't generate field code directly
    return null;
  }
}
