import 'package:code_builder/code_builder.dart' as cb;
import 'package:dpug_code_builder/src/plugins/plugins.dart';
import 'package:dpug_code_builder/src/specs/specs.dart';
import 'package:test/test.dart';

void main() {
  group('Unified Plugin System', () {
    test('should have core plugins registered', () {
      expect(isAnnotationSupported('stateful'), isTrue);
      expect(isAnnotationSupported('stateless'), isTrue);
      expect(isAnnotationSupported('listen'), isTrue);
      expect(isAnnotationSupported('changeNotifier'), isTrue);
    });

    test('should not support unknown annotations', () {
      expect(isAnnotationSupported('unknown'), isFalse);
      expect(isAnnotationSupported('customPlugin'), isFalse);
    });

    test('should get plugins by annotation name', () {
      final statefulPlugin = getPlugin('stateful');
      expect(statefulPlugin, isNotNull);
      expect(statefulPlugin!.annotationName, equals('stateful'));
      expect(statefulPlugin.priority, equals(100));

      final listenPlugin = getPlugin('listen');
      expect(listenPlugin, isNotNull);
      expect(listenPlugin!.annotationName, equals('listen'));
      expect(listenPlugin.priority, equals(80));
    });

    test('should register custom plugins', () {
      const customPlugin = TestPlugin();
      registerPlugin(customPlugin);

      expect(isAnnotationSupported('test'), isTrue);
      final retrieved = getPlugin('test');
      expect(retrieved, equals(customPlugin));
    });

    test('should process class annotations for DPug conversion', () {
      final classSpec = cb.Class(
        (final b) => b
          ..name = 'TestWidget'
          ..methods.add(
            cb.Method(
              (final b) => b
                ..name = 'build'
                ..returns = cb.refer('Widget'),
            ),
          ),
      );

      final existingAnnotations = <DpugAnnotationSpec>[];
      final result = pluginRegistry.processClassAnnotations(
        classSpec: classSpec,
        existingAnnotations: existingAnnotations,
      );

      // Should detect @stateless based on heuristic
      expect(result, isNotEmpty);
      expect(result.any((final a) => a.name == 'stateless'), isTrue);
    });

    test('should process field annotations for DPug conversion', () {
      final fieldSpec = cb.Field(
        (final b) => b
          ..name = 'controller'
          ..type = cb.refer('TextEditingController'),
      );

      final result = pluginRegistry.processFieldAnnotations(
        fieldSpec: fieldSpec,
      );

      // Should detect @changeNotifier based on heuristic
      expect(result, isNotNull);
      expect(result!.name, equals('changeNotifier'));
    });
  });
}

/// Test plugin for testing purposes
class TestPlugin extends ClassPlugin {
  const TestPlugin();

  @override
  String get annotationName => 'test';

  @override
  int get priority => 50;
}
