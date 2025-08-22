import 'package:code_builder/code_builder.dart' as cb;
import '../../ast_builder.dart';
import '../annotation_plugins.dart';
import '../../../dpug_core.dart';

/// {@template change_notifier_plugin}
/// Core plugin that handles @changeNotifier annotation for ChangeNotifier-based state management.
///
/// This plugin generates ChangeNotifier implementations with automatic disposal logic.
/// When used in @stateful widgets, it automatically generates dispose() calls for all
/// ChangeNotifier fields to prevent memory leaks.
///
/// Features:
/// - Generates ChangeNotifier field implementations
/// - Automatic disposal in stateful widgets
/// - Memory leak prevention
/// - Flutter best practices enforcement
/// - Integration with Flutter's ChangeNotifier pattern
/// {@endtemplate}
class ChangeNotifierPlugin implements AnnotationPlugin {
  /// {@macro change_notifier_plugin}
  const ChangeNotifierPlugin();

  @override
  String get annotationName => 'changeNotifier';

  @override
  bool canHandle(final String annotationName) =>
      annotationName == this.annotationName;

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
  cb.Spec? generateClassCode({
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
        return cb.Code('''
          // Auto-generated dispose logic for @changeNotifier fields
          @override
          void dispose() {
            ${changeNotifierFields.map((final name) => '_dispose${name.toUpperCase()}();').join('\n            ')}
            super.dispose();
          }
        ''');
      }
    }
    return null;
  }

  @override
  cb.Spec? generateFieldCode({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final Map<String, dynamic> context,
  }) {
    // Generate ChangeNotifier property code
    return cb.Code('''
      // ChangeNotifier field implementation
      late final ${field.type} _${field.name}Notifier = ${field.type}();

      ${field.type} get ${field.name} => _${field.name}Notifier;

      // Auto-dispose logic for stateful widgets
      // This will be automatically called in the widget's dispose() method
      void _dispose${field.name.toUpperCase()}() {
        _${field.name}Notifier.dispose();
      }
    ''');
  }
}
