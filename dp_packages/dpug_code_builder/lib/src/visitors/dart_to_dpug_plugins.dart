import 'package:code_builder/code_builder.dart' as cb;

import '../specs/specs.dart';

/// Interface for plugins that can process Dart to DPug conversion
abstract class DartToDpugPlugin {
  /// The annotation name this plugin handles (without @)
  String get annotationName;

  /// Whether this plugin can handle the given annotation
  bool canHandle(final String annotationName) =>
      annotationName == this.annotationName;

  /// Process a class during Dart to DPug conversion
  List<DpugAnnotationSpec> processClass({
    required final cb.Class classSpec,
    required final List<DpugAnnotationSpec> existingAnnotations,
  });

  /// Process a field during Dart to DPug conversion
  DpugAnnotationSpec? processField({required final cb.Field fieldSpec});
}

/// Registry for managing Dart to DPug conversion plugins
class DartToDpugPluginRegistry {
  factory DartToDpugPluginRegistry() => _instance;

  DartToDpugPluginRegistry._internal() {
    // Register core plugins automatically
    _registerCorePlugins();
  }

  void _registerCorePlugins() {
    _plugins['stateful'] = const StatefulConversionPlugin();
    _plugins['stateless'] = const StatelessConversionPlugin();
    _plugins['listen'] = const ListenConversionPlugin();
    _plugins['changeNotifier'] = const ChangeNotifierConversionPlugin();
  }

  static final DartToDpugPluginRegistry _instance =
      DartToDpugPluginRegistry._internal();

  final Map<String, DartToDpugPlugin> _plugins = {};

  /// Register a new plugin
  void registerPlugin(final DartToDpugPlugin plugin) {
    _plugins[plugin.annotationName] = plugin;
  }

  /// Get plugin for annotation
  DartToDpugPlugin? getPlugin(final String annotationName) =>
      _plugins[annotationName];

  /// Check if annotation is supported
  bool isAnnotationSupported(final String annotationName) =>
      _plugins.containsKey(annotationName);

  /// Process class annotations using plugins
  List<DpugAnnotationSpec> processClassAnnotations({
    required final cb.Class classSpec,
    required final List<DpugAnnotationSpec> existingAnnotations,
  }) {
    final result = <DpugAnnotationSpec>[...existingAnnotations];

    // Check if any plugin wants to add annotations based on class analysis
    for (final plugin in _plugins.values) {
      final additionalAnnotations = plugin.processClass(
        classSpec: classSpec,
        existingAnnotations: result,
      );
      result.addAll(additionalAnnotations);
    }

    return result;
  }

  /// Process field annotations using plugins
  DpugAnnotationSpec? processFieldAnnotations({
    required final cb.Field fieldSpec,
  }) {
    // Check if any plugin can determine the annotation for this field
    for (final plugin in _plugins.values) {
      final annotation = plugin.processField(fieldSpec: fieldSpec);
      if (annotation != null) {
        return annotation;
      }
    }

    // Default fallback for fields that don't match any plugin patterns
    return DpugAnnotationSpec.state();
  }
}

/// Core plugin that handles @stateful annotation detection during Dart to DPug conversion
class StatefulConversionPlugin implements DartToDpugPlugin {
  const StatefulConversionPlugin();

  @override
  String get annotationName => 'stateful';

  @override
  bool canHandle(final String annotationName) =>
      annotationName == this.annotationName;

  @override
  List<DpugAnnotationSpec> processClass({
    required final cb.Class classSpec,
    required final List<DpugAnnotationSpec> existingAnnotations,
  }) {
    // Heuristic: treat any class with a 'build' method returning Widget as stateful
    final hasBuild = classSpec.methods.any(
      (final m) => (m.name ?? '') == 'build',
    );

    if (hasBuild &&
        !existingAnnotations.any((final a) => a.name == 'stateful')) {
      return [DpugAnnotationSpec.stateful()];
    }

    return [];
  }

  @override
  DpugAnnotationSpec? processField({required final cb.Field fieldSpec}) {
    return null; // @stateful doesn't process individual fields
  }
}

/// Core plugin that handles @stateless annotation detection during Dart to DPug conversion
class StatelessConversionPlugin implements DartToDpugPlugin {
  const StatelessConversionPlugin();

  @override
  String get annotationName => 'stateless';

  @override
  bool canHandle(final String annotationName) =>
      annotationName == this.annotationName;

  @override
  List<DpugAnnotationSpec> processClass({
    required final cb.Class classSpec,
    required final List<DpugAnnotationSpec> existingAnnotations,
  }) {
    // Heuristic: treat any class with a 'build' method but no state fields as stateless
    final hasBuild = classSpec.methods.any(
      (final m) => (m.name ?? '') == 'build',
    );
    final hasStateFields = classSpec.fields.any(
      (final f) => f.modifier == cb.FieldModifier.var$,
    );

    if (hasBuild &&
        !hasStateFields &&
        !existingAnnotations.any((final a) => a.name == 'stateless')) {
      return [DpugAnnotationSpec.stateless()];
    }

    return [];
  }

  @override
  DpugAnnotationSpec? processField({required final cb.Field fieldSpec}) {
    return null; // @stateless doesn't process individual fields
  }
}

/// Core plugin that handles @listen annotation detection during Dart to DPug conversion
class ListenConversionPlugin implements DartToDpugPlugin {
  const ListenConversionPlugin();

  @override
  String get annotationName => 'listen';

  @override
  bool canHandle(final String annotationName) =>
      annotationName == this.annotationName;

  @override
  List<DpugAnnotationSpec> processClass({
    required final cb.Class classSpec,
    required final List<DpugAnnotationSpec> existingAnnotations,
  }) {
    // @listen is a field annotation, not class annotation
    return [];
  }

  @override
  DpugAnnotationSpec? processField({required final cb.Field fieldSpec}) {
    // Heuristic: detect reactive fields (getters and setters with setState)
    // This is a simplified heuristic - in practice, we might need more sophisticated analysis
    final fieldName = fieldSpec.name;
    final hasGetter = fieldSpec.toString().contains('get $fieldName');
    final hasSetter = fieldSpec.toString().contains('set $fieldName');

    if (hasGetter && hasSetter) {
      return DpugAnnotationSpec.listen();
    }

    return null;
  }
}

/// Core plugin that handles @changeNotifier annotation detection during Dart to DPug conversion
class ChangeNotifierConversionPlugin implements DartToDpugPlugin {
  const ChangeNotifierConversionPlugin();

  @override
  String get annotationName => 'changeNotifier';

  @override
  bool canHandle(final String annotationName) =>
      annotationName == this.annotationName;

  @override
  List<DpugAnnotationSpec> processClass({
    required final cb.Class classSpec,
    required final List<DpugAnnotationSpec> existingAnnotations,
  }) {
    // @changeNotifier is a field annotation, not class annotation
    return [];
  }

  @override
  DpugAnnotationSpec? processField({required final cb.Field fieldSpec}) {
    // Heuristic: detect ChangeNotifier fields
    final fieldType = fieldSpec.type?.toString() ?? '';

    if (fieldType.contains('ChangeNotifier') ||
        fieldType.contains('ValueNotifier') ||
        fieldType.contains('TextEditingController') ||
        fieldType.contains('ScrollController')) {
      return DpugAnnotationSpec.changeNotifier();
    }

    return null;
  }
}
