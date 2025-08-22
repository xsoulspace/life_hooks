import 'package:code_builder/code_builder.dart' as cb;

import '../../../dpug_core.dart';
import '../annotation_plugins.dart';

/// {@template listen_plugin}
/// Core plugin that handles @listen annotation for reactive state management.
///
/// This plugin generates getter/setter pairs that automatically call setState()
/// when the field value changes, providing reactive state management for Flutter widgets.
///
/// Features:
/// - Generates reactive getter/setter pairs
/// - Automatically calls setState() on value changes
/// - Integrates with Flutter's state management
/// - Provides simple reactive state without ChangeNotifier complexity
/// {@endtemplate}
class ListenPlugin implements AnnotationPlugin {
  /// {@macro listen_plugin}
  const ListenPlugin();

  @override
  String get annotationName => 'listen';

  @override
  bool canHandle(final String annotationName) =>
      annotationName == this.annotationName;

  @override
  void processClassAnnotation({
    required final String annotationName,
    required final ClassNode classNode,
    final DpugConverter? converter,
  }) {
    throw StateError('@listen can only be applied to fields, not classes');
  }

  @override
  void processFieldAnnotation({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    final DpugConverter? converter,
  }) {
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
    // Generate reactive getter/setter pair
    return cb.Code('''
      // @listen field implementation
      late ${field.type} _${field.name} = ${field.initializer ?? 'null'};

      ${field.type} get ${field.name} => _${field.name};
      set ${field.name}(${field.type} value) => setState(() => _${field.name} = value);
    ''');
  }
}
