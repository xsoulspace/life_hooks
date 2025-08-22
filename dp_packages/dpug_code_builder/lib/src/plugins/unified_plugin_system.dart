import 'package:code_builder/code_builder.dart' as cb;

import '../specs/specs.dart';
import 'core_plugins.dart';

/// Base interface for all DPUG plugins that can operate across different contexts
abstract class UnifiedPlugin {
  /// {@template unified_plugin}
  /// Base interface for all DPUG plugins that can operate across different contexts
  /// {@endtemplate}
  const UnifiedPlugin();

  /// The annotation name this plugin handles (without @)
  String get annotationName;

  /// Whether this plugin can handle the given annotation
  bool canHandle(final String annotationName) =>
      annotationName == this.annotationName;

  /// Priority for plugin execution (higher = executed first)
  int get priority => 0;

  /// Process a class annotation during compilation
  void processClassAnnotation({
    required final String annotationName,
    required final classNode,
    final converter,
  }) {}

  /// Process a field annotation during compilation
  void processFieldAnnotation({
    required final String annotationName,
    required final field,
    required final classNode,
    final converter,
  }) {}

  /// Generate code for a class annotation
  cb.Spec? generateClassCode({
    required final String annotationName,
    required final classNode,
    required final Map<String, dynamic> context,
  }) => null;

  /// Generate code for a field annotation
  cb.Spec? generateFieldCode({
    required final String annotationName,
    required final field,
    required final classNode,
    required final Map<String, dynamic> context,
  }) => null;

  /// Process class during Dart to DPug conversion
  List<DpugAnnotationSpec> processClassForDpug({
    required final cb.Class classSpec,
    required final List<DpugAnnotationSpec> existingAnnotations,
  }) => [];

  /// Process field during Dart to DPug conversion
  DpugAnnotationSpec? processFieldForDpug({
    required final cb.Field fieldSpec,
  }) => null;
}

/// Plugin that handles class-level annotations
abstract class ClassPlugin extends UnifiedPlugin {
  /// {@macro unified_plugin}
  const ClassPlugin();

  @override
  void processFieldAnnotation({
    required final String annotationName,
    required final field,
    required final classNode,
    final converter,
  }) {
    throw StateError(
      '@$annotationName can only be applied to classes, not fields',
    );
  }

  @override
  DpugAnnotationSpec? processFieldForDpug({
    required final cb.Field fieldSpec,
  }) => null;
}

/// Plugin that handles field-level annotations
abstract class FieldPlugin extends UnifiedPlugin {
  /// {@macro unified_plugin}
  const FieldPlugin();

  @override
  void processClassAnnotation({
    required final String annotationName,
    required final classNode,
    final converter,
  }) {
    throw StateError(
      '@$annotationName can only be applied to fields, not classes',
    );
  }

  @override
  List<DpugAnnotationSpec> processClassForDpug({
    required final cb.Class classSpec,
    required final List<DpugAnnotationSpec> existingAnnotations,
  }) => [];
}

/// Unified registry for managing all DPUG plugins
class UnifiedPluginRegistry {
  factory UnifiedPluginRegistry() => _instance;

  UnifiedPluginRegistry._internal() {
    _registerCorePlugins();
  }

  static final UnifiedPluginRegistry _instance =
      UnifiedPluginRegistry._internal();

  final Map<String, UnifiedPlugin> _plugins = {};

  /// Register a new plugin
  void registerPlugin(final UnifiedPlugin plugin) {
    _plugins[plugin.annotationName] = plugin;
  }

  /// Get plugin for annotation
  UnifiedPlugin? getPlugin(final String annotationName) =>
      _plugins[annotationName];

  /// Check if annotation is supported
  bool isAnnotationSupported(final String annotationName) =>
      _plugins.containsKey(annotationName);

  /// Get all registered plugins sorted by priority
  List<UnifiedPlugin> getAllPlugins() =>
      _plugins.values.toList()
        ..sort((final a, final b) => b.priority.compareTo(a.priority));

  // === COMPILER CONTEXT METHODS ===
  void processClassAnnotation({
    required final String annotationName,
    required final classNode,
    final converter,
  }) {
    final plugin = getPlugin(annotationName);
    if (plugin != null) {
      plugin.processClassAnnotation(
        annotationName: annotationName,
        classNode: classNode,
        converter: converter,
      );
    }
  }

  void processFieldAnnotation({
    required final String annotationName,
    required final field,
    required final classNode,
    final converter,
  }) {
    final plugin = getPlugin(annotationName);
    if (plugin != null) {
      plugin.processFieldAnnotation(
        annotationName: annotationName,
        field: field,
        classNode: classNode,
        converter: converter,
      );
    }
  }

  cb.Spec? generateClassCode({
    required final String annotationName,
    required final classNode,
    required final Map<String, dynamic> context,
  }) {
    final plugin = getPlugin(annotationName);
    return plugin?.generateClassCode(
      annotationName: annotationName,
      classNode: classNode,
      context: context,
    );
  }

  cb.Spec? generateFieldCode({
    required final String annotationName,
    required final field,
    required final classNode,
    required final Map<String, dynamic> context,
  }) {
    final plugin = getPlugin(annotationName);
    return plugin?.generateFieldCode(
      annotationName: annotationName,
      field: field,
      classNode: classNode,
      context: context,
    );
  }

  // === DPUG TO DART CONVERSION METHODS ===
  cb.Spec? generateClassCodeForConversion({
    required final DpugClassSpec classSpec,
    required final Map<String, dynamic> context,
  }) {
    for (final annotation in classSpec.annotations) {
      final plugin = getPlugin(annotation.name);
      if (plugin != null) {
        final result = plugin.generateClassCode(
          annotationName: annotation.name,
          classNode: classSpec,
          context: context,
        );
        if (result != null) {
          return result;
        }
      }
    }
    return null;
  }

  cb.Spec? generateFieldCodeForConversion({
    required final DpugStateFieldSpec fieldSpec,
    required final Map<String, dynamic> context,
  }) {
    final plugin = getPlugin(fieldSpec.annotation.name);
    return plugin?.generateFieldCode(
      annotationName: fieldSpec.annotation.name,
      field: fieldSpec,
      classNode: null,
      context: context,
    );
  }

  // === DART TO DPUG CONVERSION METHODS ===
  List<DpugAnnotationSpec> processClassAnnotations({
    required final cb.Class classSpec,
    required final List<DpugAnnotationSpec> existingAnnotations,
  }) {
    final result = <DpugAnnotationSpec>[...existingAnnotations];

    for (final plugin in getAllPlugins()) {
      final additionalAnnotations = plugin.processClassForDpug(
        classSpec: classSpec,
        existingAnnotations: result,
      );
      result.addAll(additionalAnnotations);
    }

    return result;
  }

  DpugAnnotationSpec? processFieldAnnotations({
    required final cb.Field fieldSpec,
  }) {
    for (final plugin in getAllPlugins()) {
      final annotation = plugin.processFieldForDpug(fieldSpec: fieldSpec);
      if (annotation != null) {
        return annotation;
      }
    }
    return DpugAnnotationSpec.state();
  }

  void _registerCorePlugins() {
    // Register all core plugins in priority order
    registerPlugin(const StatefulPlugin());
    registerPlugin(const StatelessPlugin());
    registerPlugin(const ListenPlugin());
    registerPlugin(const ChangeNotifierPlugin());
  }
}
