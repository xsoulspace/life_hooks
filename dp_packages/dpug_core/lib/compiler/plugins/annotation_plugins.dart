import 'package:code_builder/code_builder.dart' as cb;

import '../../dpug_core.dart';

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
    // Register built-in plugins
    _plugins['stateful'] = StatefulAnnotationPlugin();
    _plugins['listen'] = ListenAnnotationPlugin();
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

/// Built-in plugin for @stateful annotation
class StatefulAnnotationPlugin implements AnnotationPlugin {
  @override
  String get annotationName => 'stateful';

  @override
  void processClassAnnotation({
    required final String annotationName,
    required final ClassNode classNode,
    required final DpugConverter converter,
  }) {
    // Mark class as stateful - this affects code generation
    // The actual code generation logic remains in the existing code
    // This plugin just validates and prepares the class for stateful generation
    print('Processing @stateful annotation for class ${classNode.name}');
  }

  @override
  void processFieldAnnotation({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final DpugConverter converter,
  }) {
    // @stateful is a class annotation, not field annotation
    throw StateError('@stateful can only be applied to classes, not fields');
  }

  @override
  cb.Spec? generateClassCode({
    required final String annotationName,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // Return a special marker that indicates this should generate stateful code
    // The actual generation is handled by the existing code generation logic
    return const cb.Code('__STATEFUL_CLASS__');
  }

  @override
  cb.Spec? generateFieldCode({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // @stateful doesn't generate field code
    return null;
  }
}

/// Built-in plugin for @listen annotation
class ListenAnnotationPlugin implements AnnotationPlugin {
  @override
  String get annotationName => 'listen';

  @override
  void processClassAnnotation({
    required final String annotationName,
    required final ClassNode classNode,
    required final DpugConverter converter,
  }) {
    // @listen is a field annotation, not class annotation
    throw StateError('@listen can only be applied to fields, not classes');
  }

  @override
  void processFieldAnnotation({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final DpugConverter converter,
  }) {
    // Mark field as listenable - this affects state management generation
    // The actual code generation logic remains in the existing code
    // This plugin just validates and prepares the field for listenable generation
    print(
      'Processing @listen annotation for field ${field.name} in class ${classNode.name}',
    );
  }

  @override
  cb.Spec? generateClassCode({
    required final String annotationName,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // @listen doesn't generate class code
    return null;
  }

  @override
  cb.Spec? generateFieldCode({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // Return a special marker that indicates this field should be listenable
    // The actual generation is handled by the existing code generation logic
    return const cb.Code('__LISTENABLE_FIELD__');
  }
}

/// Example of how a developer could create their own annotation plugin
class ExampleCustomPlugin implements AnnotationPlugin {
  @override
  String get annotationName => 'computed';

  @override
  void processClassAnnotation({
    required final String annotationName,
    required final ClassNode classNode,
    required final DpugConverter converter,
  }) {
    throw StateError('@computed can only be applied to methods, not classes');
  }

  @override
  void processFieldAnnotation({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final DpugConverter converter,
  }) {
    // Custom logic for computed properties
    // This could generate getter methods with caching, dependency tracking, etc.
    print('Processing @computed annotation for field ${field.name}');
  }

  @override
  cb.Spec? generateClassCode({
    required final String annotationName,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // @computed doesn't generate class code
    return null;
  }

  @override
  cb.Spec? generateFieldCode({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // Custom computed property generation
    // This could generate a getter with caching logic
    return const cb.Code('__COMPUTED_PROPERTY__');
  }
}
