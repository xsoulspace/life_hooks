import 'package:code_builder/code_builder.dart' as cb;

import 'unified_plugin_system.dart';

/// Compatibility layer for dpug_core to use the unified plugin system
///
/// This adapter allows dpug_core to continue using its existing interfaces
/// while benefiting from the unified plugin system under the hood.

/// Adapter that implements the dpug_core AnnotationPlugin interface
/// using the unified plugin system
class UnifiedAnnotationPluginAdapter {
  final UnifiedPluginRegistry _registry = UnifiedPluginRegistry();

  /// Process a class annotation (dpug_core compatibility)
  void processClassAnnotation({
    required final String annotationName,
    required final classNode,
    final converter,
  }) {
    _registry.processClassAnnotation(
      annotationName: annotationName,
      classNode: classNode,
      converter: converter,
    );
  }

  /// Process a field annotation (dpug_core compatibility)
  void processFieldAnnotation({
    required final String annotationName,
    required final field,
    required final classNode,
    final converter,
  }) {
    _registry.processFieldAnnotation(
      annotationName: annotationName,
      field: field,
      classNode: classNode,
      converter: converter,
    );
  }

  /// Generate code for a class annotation (dpug_core compatibility)
  cb.Spec? generateClassCode({
    required final String annotationName,
    required final classNode,
    required final Map<String, dynamic> context,
  }) => _registry.generateClassCode(
    annotationName: annotationName,
    classNode: classNode,
    context: context,
  );

  /// Generate code for a field annotation (dpug_core compatibility)
  cb.Spec? generateFieldCode({
    required final String annotationName,
    required final field,
    required final classNode,
    required final Map<String, dynamic> context,
  }) => _registry.generateFieldCode(
    annotationName: annotationName,
    field: field,
    classNode: classNode,
    context: context,
  );

  /// Check if annotation is supported (dpug_core compatibility)
  bool isAnnotationSupported(final String annotationName) =>
      _registry.isAnnotationSupported(annotationName);

  /// Get plugin for annotation (dpug_core compatibility)
  UnifiedPlugin? getPlugin(final String annotationName) =>
      _registry.getPlugin(annotationName);

  /// Register a new plugin (dpug_core compatibility)
  void registerPlugin(final UnifiedPlugin plugin) {
    _registry.registerPlugin(plugin);
  }
}

/// Global instance for dpug_core compatibility
final dpugCorePluginRegistry = UnifiedAnnotationPluginAdapter();
