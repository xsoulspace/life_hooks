import 'package:dpug_core/compiler/plugins/annotation_plugins.dart';
import 'package:dpug_core/dpug_core.dart';

/// Example: Creating a custom @changeNotifier annotation plugin
class ChangeNotifierPlugin implements AnnotationPlugin {
  @override
  String get annotationName => 'changeNotifier';

  @override
  void processClassAnnotation({
    required final String annotationName,
    required final ClassNode classNode,
    required final DpugConverter converter,
  }) {
    throw StateError(
      '@changeNotifier can only be applied to fields, not classes',
    );
  }

  @override
  void processFieldAnnotation({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final DpugConverter converter,
  }) {
    print('Setting up ChangeNotifier field: ${field.name}');
    // Here you could set up change notification systems
  }

  @override
  dynamic generateClassCode({
    required final String annotationName,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    return null; // @observable doesn't generate class code
  }

  @override
  dynamic generateFieldCode({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // Generate ChangeNotifier property code
    return '''
      // ChangeNotifier field implementation
      late final ${field.type} _${field.name}Notifier = ${field.type}();

      ${field.type} get ${field.name} => _${field.name}Notifier;

      // Auto-dispose logic for stateful widgets
      // This will be automatically called in the widget's dispose() method
      void _dispose${field.name.toUpperCase()}() {
        _${field.name}Notifier.dispose();
      }
    ''';
  }

  @override
  dynamic generateClassCode({
    required final String annotationName,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // Check if this is a stateful widget and generate dispose logic
    final hasStatefulAnnotation = classNode.annotations.contains('stateful');
    if (hasStatefulAnnotation) {
      // Find all @changeNotifier fields in this class
      final changeNotifierFields = classNode.stateVariables
          .where((final field) => field.annotation == 'changeNotifier')
          .map((final field) => field.name)
          .toList();

      if (changeNotifierFields.isNotEmpty) {
        return '''
          // Auto-generated dispose logic for @changeNotifier fields
          @override
          void dispose() {
            ${changeNotifierFields.map((final name) => '_dispose${name.toUpperCase()}();').join('\n            ')}
            super.dispose();
          }
        ''';
      }
    }
    return null;
  }
}

/// Example: Creating a custom @stateless annotation plugin (complement to @stateful)
class StatelessPlugin implements AnnotationPlugin {
  @override
  String get annotationName => 'stateless';

  @override
  void processClassAnnotation({
    required final String annotationName,
    required final ClassNode classNode,
    required final DpugConverter converter,
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
    required final DpugConverter converter,
  }) {
    throw StateError('@stateless can only be applied to classes, not fields');
  }

  @override
  dynamic generateClassCode({
    required final String annotationName,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // Return a special marker that indicates this should generate stateless code
    return '__STATELESS_WIDGET__';
  }

  @override
  dynamic generateFieldCode({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // @stateless doesn't generate field code
    return null;
  }
}

/// Example: Creating a custom @persist annotation for persistent state
class PersistPlugin implements AnnotationPlugin {
  @override
  String get annotationName => 'persist';

  @override
  void processClassAnnotation({
    required final String annotationName,
    required final ClassNode classNode,
    required final DpugConverter converter,
  }) {
    throw StateError('@persist can only be applied to fields, not classes');
  }

  @override
  void processFieldAnnotation({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final DpugConverter converter,
  }) {
    print('Setting up persistence for field: ${field.name}');
    // Here you could configure storage backends
  }

  @override
  dynamic generateClassCode({
    required final String annotationName,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    return null; // @persist doesn't generate class code
  }

  @override
  dynamic generateFieldCode({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // Generate persistent property code
    return '''
      // Persistent field implementation
      ${field.type} get ${field.name} {
        return _prefs.get('${field.name}') ?? ${field.initializer ?? 'null'};
      }

      set ${field.name}(${field.type} value) {
        _${field.name}Value = value;
        _prefs.set('${field.name}', value);
      }
    ''';
  }
}

/// Example: How to use custom plugins
void main() {
  // Get the plugin registry
  final registry = AnnotationPluginRegistry();

  // Register custom plugins
  registry.registerPlugin(ChangeNotifierPlugin());
  registry.registerPlugin(PersistPlugin());
  registry.registerPlugin(StatelessPlugin());

  // Now these annotations can be used in DPUG code:
  const dpugCode = r'''
  @stateful
  class MyStatefulWidget
    @changeNotifier @persist String username = 'guest'
    @listen int counter = 0

    Widget get build =>
      Column
        Text
          ..'Hello, $username!'
        ElevatedButton
          ..onPressed: () => counter++
          Text
            ..'Count: $counter'

  @stateless
  class MyStatelessWidget
    Widget get build =>
      Container
        ..padding: EdgeInsets.all(16)
        Text
          ..'This is a stateless widget'
  ''';

  // The converter will now use the registered plugins
  final converter = DpugConverter();
  final dartCode = converter.dpugToDart(dpugCode);

  print('Generated Dart code with custom plugins:');
  print(dartCode);
}

/// Example: Plugin composition and chaining
class ValidationPlugin implements AnnotationPlugin {
  @override
  String get annotationName => 'validate';

  @override
  void processClassAnnotation({
    required final String annotationName,
    required final ClassNode classNode,
    required final DpugConverter converter,
  }) {
    throw StateError('@validate can only be applied to fields, not classes');
  }

  @override
  void processFieldAnnotation({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final DpugConverter converter,
  }) {
    print('Setting up validation for field: ${field.name}');
  }

  @override
  dynamic generateClassCode({
    required final String annotationName,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) => null;

  @override
  dynamic generateFieldCode({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // Generate validation wrapper
    return '''
      // Validation wrapper
      ${field.type} get ${field.name} => _${field.name}Value;
      set ${field.name}(${field.type} value) {
        if (_validate${field.name.toUpperCase()}(value)) {
          _${field.name}Value = value;
        } else {
          throw ValidationException('Invalid value for ${field.name}');
        }
      }

      bool _validate${field.name.toUpperCase()}(${field.type} value) {
        // Custom validation logic here
        return true; // Placeholder
      }
    ''';
  }
}
