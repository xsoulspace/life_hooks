import 'package:code_builder/code_builder.dart' as cb;

import '../../dpug_core.dart';

// Core plugins
import 'core/stateful_plugin.dart';
import 'core/stateless_plugin.dart';
import 'core/listen_plugin.dart';
import 'core/change_notifier_plugin.dart';

/// Interface for annotation plugins that can process specific annotations
abstract class AnnotationPlugin {
  /// The annotation name this plugin handles (without @)
  String get annotationName;

  /// Whether this plugin can handle the given annotation
  bool canHandle(final String annotationName) =>
      annotationName == this.annotationName;

  /// Process a class annotation
  void processClassAnnotation({
    required final String annotationName,
    required final ClassNode classNode,
    required final DpugConverter converter,
  });

  /// Process a field annotation
  void processFieldAnnotation({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final DpugConverter converter,
  });

  /// Generate code for a class annotation
  cb.Spec? generateClassCode({
    required final String annotationName,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  });

  /// Generate code for a field annotation
  cb.Spec? generateFieldCode({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  });
}

/// Registry for managing annotation plugins
class AnnotationPluginRegistry {
  factory AnnotationPluginRegistry() => _instance;

  AnnotationPluginRegistry._internal() {
    // Register core plugins automatically
    _registerCorePlugins();
  }

  void _registerCorePlugins() {
    _plugins['stateful'] = const StatefulPlugin();
    _plugins['stateless'] = const StatelessPlugin();
    _plugins['listen'] = const ListenPlugin();
    _plugins['changeNotifier'] = const ChangeNotifierPlugin();
  }

  static final AnnotationPluginRegistry _instance =
      AnnotationPluginRegistry._internal();

  final Map<String, AnnotationPlugin> _plugins = {};

  /// Register a new annotation plugin
  void registerPlugin(final AnnotationPlugin plugin) {
    _plugins[plugin.annotationName] = plugin;
  }

  /// Get plugin for annotation
  AnnotationPlugin? getPlugin(final String annotationName) =>
      _plugins[annotationName];

  /// Check if annotation is supported
  bool isAnnotationSupported(final String annotationName) =>
      _plugins.containsKey(annotationName);

  /// Process class annotation using appropriate plugin
  void processClassAnnotation({
    required final String annotationName,
    required final ClassNode classNode,
    required final DpugConverter converter,
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

  /// Process field annotation using appropriate plugin
  void processFieldAnnotation({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final DpugConverter converter,
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
}
