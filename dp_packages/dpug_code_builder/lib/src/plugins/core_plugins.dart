import 'package:code_builder/code_builder.dart' as cb;

import '../specs/specs.dart';
import 'unified_plugin_system.dart';

/// {@template stateful_plugin}
/// Core plugin that handles @stateful annotation for generating StatefulWidget classes.
///
/// This plugin transforms classes annotated with @stateful into proper StatefulWidget
/// implementations with automatic state class generation.
///
/// Features:
/// - Converts class fields to state variables
/// - Generates StatefulWidget and State classes
/// - Handles constructor parameters properly
/// - Integrates with other plugins like @changeNotifier
/// {@endtemplate}
class StatefulPlugin extends ClassPlugin {
  /// {@macro stateful_plugin}
  const StatefulPlugin();

  @override
  String get annotationName => 'stateful';

  @override
  int get priority => 100; // High priority for core functionality

  @override
  void processClassAnnotation({
    required final String annotationName,
    required final classNode,
    final converter,
  }) {
    // Validate that this class can be stateful
    // Additional validation logic can be added here
    print(
      'Processing @stateful annotation for class ${classNode?.name ?? 'unknown'}',
    );
  }

  @override
  cb.Spec? generateClassCode({
    required final String annotationName,
    required final classNode,
    required final Map<String, dynamic> context,
  }) {
    // Return a marker for the visitor to handle the actual generation
    return const cb.Code('__STATEFUL_WIDGET__');
  }

  @override
  List<DpugAnnotationSpec> processClassForDpug({
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
}

/// {@template stateless_plugin}
/// Core plugin that handles @stateless annotation for generating StatelessWidget classes.
///
/// This plugin transforms classes annotated with @stateless into proper StatelessWidget
/// implementations with automatic build method handling.
///
/// Features:
/// - Generates StatelessWidget classes
/// - Handles build method properly
/// - Integrates with field plugins
/// {@endtemplate}
class StatelessPlugin extends ClassPlugin {
  /// {@macro stateless_plugin}
  const StatelessPlugin();

  @override
  String get annotationName => 'stateless';

  @override
  int get priority => 90;

  @override
  void processClassAnnotation({
    required final String annotationName,
    required final classNode,
    final converter,
  }) {
    print(
      'Processing @stateless annotation for class ${classNode?.name ?? 'unknown'}',
    );
  }

  @override
  cb.Spec? generateClassCode({
    required final String annotationName,
    required final classNode,
    required final Map<String, dynamic> context,
  }) {
    // Return a marker for the visitor to handle the actual generation
    return const cb.Code('__STATELESS_WIDGET__');
  }

  @override
  List<DpugAnnotationSpec> processClassForDpug({
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
}

/// {@template listen_plugin}
/// Core plugin that handles @listen annotation for reactive state fields.
///
/// This plugin transforms fields annotated with @listen into reactive state variables
/// with automatic getter/setter generation and state management.
///
/// Features:
/// - Generates reactive getters and setters
/// - Integrates with setState for UI updates
/// - Supports initial values and type inference
/// {@endtemplate}
class ListenPlugin extends FieldPlugin {
  /// {@macro listen_plugin}
  const ListenPlugin();

  @override
  String get annotationName => 'listen';

  @override
  int get priority => 80;

  @override
  void processFieldAnnotation({
    required final String annotationName,
    required final field,
    required final classNode,
    final converter,
  }) {
    print(
      'Processing @listen annotation for field ${field?.name ?? 'unknown'}',
    );
  }

  @override
  cb.Spec? generateFieldCode({
    required final String annotationName,
    required final field,
    required final classNode,
    required final Map<String, dynamic> context,
  }) {
    final isStateClass = context['isStateClass'] as bool? ?? false;

    if (isStateClass) {
      // For @listen fields in state classes, return the backing field
      // The getter/setter will be handled by _buildStateAccessors
      return cb.Field(
        (final b) => b
          ..name = '_${field.name}'
          ..modifier = cb.FieldModifier.var$
          ..type = cb.refer('late ${field.type}'),
      );
    } else {
      // Widget class field - no implementation needed for @listen
      return cb.Field(
        (final b) => b
          ..name = field.name
          ..type = cb.refer(field.type)
          ..modifier = cb.FieldModifier.final$,
      );
    }
  }

  @override
  DpugAnnotationSpec? processFieldForDpug({required final cb.Field fieldSpec}) {
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

/// {@template change_notifier_plugin}
/// Core plugin that handles @changeNotifier annotation for ChangeNotifier fields.
///
/// This plugin transforms fields annotated with @changeNotifier into ChangeNotifier
/// instances with automatic disposal and listener management.
///
/// Features:
/// - Generates ChangeNotifier fields with proper initialization
/// - Handles automatic disposal in dispose method
/// - Integrates with Flutter's state management
/// {@endtemplate}
class ChangeNotifierPlugin extends FieldPlugin {
  /// {@macro change_notifier_plugin}
  const ChangeNotifierPlugin();

  @override
  String get annotationName => 'changeNotifier';

  @override
  int get priority => 70;

  @override
  void processFieldAnnotation({
    required final String annotationName,
    required final field,
    required final classNode,
    final converter,
  }) {
    print(
      'Processing @changeNotifier annotation for field ${field?.name ?? 'unknown'}',
    );
  }

  @override
  cb.Spec? generateFieldCode({
    required final String annotationName,
    required final field,
    required final classNode,
    required final Map<String, dynamic> context,
  }) {
    final isStateClass = context['isStateClass'] as bool? ?? false;

    if (isStateClass) {
      // For @changeNotifier fields in state classes, return the backing field
      // The getter/dispose logic will be handled separately
      return cb.Field(
        (final b) => b
          ..name = '_${field.name}Notifier'
          ..modifier = cb.FieldModifier.final$
          ..type = cb.refer('late ${field.type}')
          ..assignment = cb.Code('${field.type}()'),
      );
    } else {
      // Widget class field - no implementation needed for @changeNotifier
      return cb.Field(
        (final b) => b
          ..name = field.name
          ..type = cb.refer(field.type)
          ..modifier = cb.FieldModifier.final$,
      );
    }
  }

  @override
  DpugAnnotationSpec? processFieldForDpug({required final cb.Field fieldSpec}) {
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
