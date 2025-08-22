import 'package:code_builder/code_builder.dart' as cb;

import '../specs/specs.dart';

/// Interface for plugins that can process DPug to Dart code generation
abstract class DpugToDartPlugin {
  /// The annotation name this plugin handles (without @)
  String get annotationName;

  /// Whether this plugin can handle the given annotation
  bool canHandle(final String annotationName) =>
      annotationName == this.annotationName;

  /// Generate code for a class annotation
  cb.Spec? generateClassCode({
    required final DpugClassSpec classSpec,
    required final Map<String, dynamic> context,
  });

  /// Generate code for a field annotation
  cb.Spec? generateFieldCode({
    required final DpugStateFieldSpec fieldSpec,
    required final Map<String, dynamic> context,
  });
}

/// Registry for managing DPug to Dart conversion plugins
class DpugToDartPluginRegistry {
  factory DpugToDartPluginRegistry() => _instance;

  DpugToDartPluginRegistry._internal() {
    // Register core plugins automatically
    _registerCorePlugins();
  }

  void _registerCorePlugins() {
    _plugins['stateful'] = const StatefulCodeGenerator();
    _plugins['stateless'] = const StatelessCodeGenerator();
    _plugins['listen'] = const ListenCodeGenerator();
    _plugins['changeNotifier'] = const ChangeNotifierCodeGenerator();
  }

  static final DpugToDartPluginRegistry _instance =
      DpugToDartPluginRegistry._internal();

  final Map<String, DpugToDartPlugin> _plugins = {};

  /// Register a new plugin
  void registerPlugin(final DpugToDartPlugin plugin) {
    _plugins[plugin.annotationName] = plugin;
  }

  /// Get plugin for annotation
  DpugToDartPlugin? getPlugin(final String annotationName) =>
      _plugins[annotationName];

  /// Check if annotation is supported
  bool isAnnotationSupported(final String annotationName) =>
      _plugins.containsKey(annotationName);

  /// Generate code for class using plugins
  cb.Spec? generateClassCode({
    required final DpugClassSpec classSpec,
    required final Map<String, dynamic> context,
  }) {
    // Check each annotation and use the first plugin that can handle it
    for (final annotation in classSpec.annotations) {
      final plugin = getPlugin(annotation.name);
      if (plugin != null) {
        return plugin.generateClassCode(classSpec: classSpec, context: context);
      }
    }
    return null;
  }

  /// Generate code for field using plugins
  cb.Spec? generateFieldCode({
    required final DpugStateFieldSpec fieldSpec,
    required final Map<String, dynamic> context,
  }) {
    final plugin = getPlugin(fieldSpec.annotation.name);
    if (plugin != null) {
      return plugin.generateFieldCode(fieldSpec: fieldSpec, context: context);
    }
    return null;
  }
}

/// Plugin for generating StatefulWidget code
class StatefulCodeGenerator implements DpugToDartPlugin {
  const StatefulCodeGenerator();

  @override
  String get annotationName => 'stateful';

  @override
  bool canHandle(final String annotationName) =>
      annotationName == this.annotationName;

  @override
  cb.Spec? generateClassCode({
    required final DpugClassSpec classSpec,
    required final Map<String, dynamic> context,
  }) {
    // For now, return a simple marker - the visitor will handle the actual generation
    return const cb.Code('__STATEFUL_WIDGET__');
  }

  @override
  cb.Spec? generateFieldCode({
    required final DpugStateFieldSpec fieldSpec,
    required final Map<String, dynamic> context,
  }) {
    return null; // @stateful doesn't handle individual fields
  }
}

/// Plugin for generating StatelessWidget code
class StatelessCodeGenerator implements DpugToDartPlugin {
  const StatelessCodeGenerator();

  @override
  String get annotationName => 'stateless';

  @override
  bool canHandle(final String annotationName) =>
      annotationName == this.annotationName;

  @override
  cb.Spec? generateClassCode({
    required final DpugClassSpec classSpec,
    required final Map<String, dynamic> context,
  }) {
    // Return a marker for the visitor to handle
    return const cb.Code('__STATELESS_WIDGET__');
  }

  @override
  cb.Spec? generateFieldCode({
    required final DpugStateFieldSpec fieldSpec,
    required final Map<String, dynamic> context,
  }) {
    return null; // @stateless doesn't handle individual fields
  }
}

/// Plugin for generating @listen field code
class ListenCodeGenerator implements DpugToDartPlugin {
  const ListenCodeGenerator();

  @override
  String get annotationName => 'listen';

  @override
  bool canHandle(final String annotationName) =>
      annotationName == this.annotationName;

  @override
  cb.Spec? generateClassCode({
    required final DpugClassSpec classSpec,
    required final Map<String, dynamic> context,
  }) {
    return null; // @listen is a field annotation
  }

  @override
  cb.Spec? generateFieldCode({
    required final DpugStateFieldSpec fieldSpec,
    required final Map<String, dynamic> context,
  }) {
    final isStateClass = context['isStateClass'] as bool;

    if (isStateClass) {
      // For @listen fields in state classes, return the backing field
      // The getter/setter will be handled by _buildStateAccessors
      return cb.Field(
        (final b) => b
          ..name = '_${fieldSpec.name}'
          ..modifier = cb.FieldModifier.var$
          ..type = cb.refer('late ${fieldSpec.type}'),
      );
    } else {
      // Widget class field - no implementation needed for @listen
      return cb.Field(
        (final b) => b
          ..name = fieldSpec.name
          ..type = cb.refer(fieldSpec.type)
          ..modifier = cb.FieldModifier.final$,
      );
    }
  }
}

/// Plugin for generating @changeNotifier field code
class ChangeNotifierCodeGenerator implements DpugToDartPlugin {
  const ChangeNotifierCodeGenerator();

  @override
  String get annotationName => 'changeNotifier';

  @override
  bool canHandle(final String annotationName) =>
      annotationName == this.annotationName;

  @override
  cb.Spec? generateClassCode({
    required final DpugClassSpec classSpec,
    required final Map<String, dynamic> context,
  }) {
    return null; // @changeNotifier is a field annotation
  }

  @override
  cb.Spec? generateFieldCode({
    required final DpugStateFieldSpec fieldSpec,
    required final Map<String, dynamic> context,
  }) {
    final isStateClass = context['isStateClass'] as bool;

    if (isStateClass) {
      // For @changeNotifier fields in state classes, return the backing field
      // The getter/dispose logic will be handled separately
      return cb.Field(
        (final b) => b
          ..name = '_${fieldSpec.name}Notifier'
          ..modifier = cb.FieldModifier.final$
          ..type = cb.refer('late ${fieldSpec.type}')
          ..assignment = cb.Code('${fieldSpec.type}()'),
      );
    } else {
      // Widget class field - no implementation needed for @changeNotifier
      return cb.Field(
        (final b) => b
          ..name = fieldSpec.name
          ..type = cb.refer(fieldSpec.type)
          ..modifier = cb.FieldModifier.final$,
      );
    }
  }
}
