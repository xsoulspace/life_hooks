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
    throw StateError('@changeNotifier can only be applied to fields, not classes');
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
    // Generate observable property code
    return '''
      // Observable field implementation
      late final StreamController<${field.type}> _${field.name}Controller = StreamController.broadcast();

      Stream<${field.type}> get ${field.name}Stream => _${field.name}Controller.stream;

      ${field.type} get ${field.name} => _${field.name}Value;
      set ${field.name}(${field.type} value) {
        _${field.name}Value = value;
        _${field.name}Controller.add(value);
      }
    ''';
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
  registry.registerPlugin(ObservablePlugin());
  registry.registerPlugin(PersistPlugin());

  // Now these annotations can be used in DPUG code:
  const dpugCode = r'''
  @stateful
  class MyWidget
    @observable @persist String username = 'guest'
    @listen int counter = 0

    Widget get build =>
      Column
        Text
          ..'Hello, $username!'
        ElevatedButton
          ..onPressed: () => counter++
          Text
            ..'Count: $counter'
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
