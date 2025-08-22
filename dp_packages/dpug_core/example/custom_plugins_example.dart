import 'package:code_builder/code_builder.dart' as cb;
import 'package:dpug_core/compiler/plugins/annotation_plugins.dart';
import 'package:dpug_core/dpug_core.dart';

/// Example: How to use custom plugins
void main() {
  // Get the plugin registry
  final registry = AnnotationPluginRegistry();

  // Core plugins are automatically registered in the registry
  // You can check which plugins are available:
  print('Available plugins:');
  print('- @stateful: ${registry.isAnnotationSupported('stateful')}');
  print('- @stateless: ${registry.isAnnotationSupported('stateless')}');
  print('- @listen: ${registry.isAnnotationSupported('listen')}');
  print(
    '- @changeNotifier: ${registry.isAnnotationSupported('changeNotifier')}',
  );

  // Example of using core plugins:
  const dpugCode = r'''
  @stateful
  class MyStatefulWidget
    @changeNotifier String username = 'guest'
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
  bool canHandle(final String annotationName) =>
      annotationName == this.annotationName;

  @override
  void processClassAnnotation({
    required final String annotationName,
    required final ClassNode classNode,
    final DpugConverter? converter,
  }) {
    throw StateError('@validate can only be applied to fields, not classes');
  }

  @override
  void processFieldAnnotation({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    final DpugConverter? converter,
  }) {
    print('Setting up validation for field: ${field.name}');
  }

  @override
  cb.Spec? generateClassCode({
    required final String annotationName,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) => null;

  @override
  cb.Spec? generateFieldCode({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // Generate validation wrapper
    return cb.Code('''
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
    ''');
  }
}
