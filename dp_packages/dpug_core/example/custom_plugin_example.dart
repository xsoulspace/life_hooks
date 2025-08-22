import 'package:code_builder/code_builder.dart' as cb;
import 'package:dpug_core/compiler/plugins/annotation_plugins.dart';
import 'package:dpug_core/compiler/ast_builder.dart';
import 'package:dpug_core/dpug_core.dart';

/// {@template computed_plugin}
/// Example custom plugin that demonstrates how to create computed properties.
///
/// This plugin shows how developers can create their own annotation plugins
/// that extend DPUG's functionality with custom behavior.
///
/// Features demonstrated:
/// - Custom annotation processing
/// - Code generation for getters with caching
/// - Integration with existing DPUG infrastructure
/// {@endtemplate}
class ComputedPlugin implements AnnotationPlugin {
  /// {@macro computed_plugin}
  const ComputedPlugin();

  @override
  String get annotationName => 'computed';

  @override
  bool canHandle(final String annotationName) =>
      annotationName == this.annotationName;

  @override
  void processClassAnnotation({
    required final String annotationName,
    required final ClassNode classNode,
    required final DpugConverter converter,
  }) {
    throw StateError('@computed can only be applied to fields, not classes');
  }

  @override
  void processFieldAnnotation({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final DpugConverter converter,
  }) {
    print('Setting up computed property: ${field.name}');
    // Here you could validate that the field has a proper computation function
    // or set up dependency tracking
  }

  @override
  cb.Spec? generateClassCode({
    required final String annotationName,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // @computed doesn't generate class-level code
    return null;
  }

  @override
  cb.Spec? generateFieldCode({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // Generate a computed property with caching
    return cb.Code('''
      // Computed property with caching
      ${field.type}? _${field.name}Cache;
      bool _${field.name}CacheValid = false;

      ${field.type} get ${field.name} {
        if (!_${field.name}CacheValid) {
          _${field.name}Cache = _compute${field.name.toUpperCase()}();
          _${field.name}CacheValid = true;
        }
        return _${field.name}Cache!;
      }

      void _invalidate${field.name.toUpperCase()}() {
        _${field.name}CacheValid = false;
      }

      ${field.type} _compute${field.name.toUpperCase()}() {
        // Implement your computation logic here
        // This could access other fields in the class
        return ${field.initializer ?? 'null'};
      }
    ''');
  }
}

/// {@template observable_plugin}
/// Another example plugin showing reactive state management.
///
/// This demonstrates how to create plugins that integrate with
/// different state management patterns.
/// {@endtemplate}
class ObservablePlugin implements AnnotationPlugin {
  /// {@macro observable_plugin}
  const ObservablePlugin();

  @override
  String get annotationName => 'observable';

  @override
  bool canHandle(final String annotationName) =>
      annotationName == this.annotationName;

  @override
  void processClassAnnotation({
    required final String annotationName,
    required final ClassNode classNode,
    required final DpugConverter converter,
  }) {
    throw StateError('@observable can only be applied to fields, not classes');
  }

  @override
  void processFieldAnnotation({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final DpugConverter converter,
  }) {
    print('Creating observable field: ${field.name}');
  }

  @override
  cb.Spec? generateClassCode({
    required final String annotationName,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // @observable doesn't generate class-level code
    return null;
  }

  @override
  cb.Spec? generateFieldCode({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // Generate observable property with stream support
    return cb.Code('''
      // Observable field with Stream support
      final StreamController<${field.type}> _${field.name}Controller =
          StreamController<${field.type}>.broadcast();

      Stream<${field.type}> get ${field.name}Stream => _${field.name}Controller.stream;

      ${field.type} _${field.name} = ${field.initializer ?? 'null'};

      ${field.type} get ${field.name} => _${field.name};

      set ${field.name}(${field.type} value) {
        _${field.name} = value;
        _${field.name}Controller.add(value);
      }
    ''');
  }
}

/// Example of how to register and use custom plugins
void main() {
  // Get the plugin registry
  final registry = AnnotationPluginRegistry();

  // Register your custom plugins
  registry.registerPlugin(const ComputedPlugin());
  registry.registerPlugin(const ObservablePlugin());

  // Now you can use these annotations in DPUG code:
  const dpugCode = '''
  @stateful
  class AdvancedWidget
    @observable String searchQuery = ''
    @computed List<String> filteredResults
    @changeNotifier MyViewModel viewModel = MyViewModel()

    Widget get build =>
      Column
        TextField
          ..controller: searchQuery
          ..onChanged: (value) => searchQuery = value
        ListView
          ..children: filteredResults.map((result) => Text(result))
  ''';

  print('Custom plugins registered successfully!');
  print('Available plugins:');
  print('- @stateful: ${registry.isAnnotationSupported('stateful')}');
  print('- @stateless: ${registry.isAnnotationSupported('stateless')}');
  print('- @listen: ${registry.isAnnotationSupported('listen')}');
  print(
    '- @changeNotifier: ${registry.isAnnotationSupported('changeNotifier')}',
  );
  print('- @computed: ${registry.isAnnotationSupported('computed')}');
  print('- @observable: ${registry.isAnnotationSupported('observable')}');
}
