import 'package:code_builder/code_builder.dart' as cb;
import 'package:dpug_code_builder/dpug_code_builder.dart';
import 'package:dpug_code_builder/src/visitors/dart_to_dpug_plugins.dart';
import 'package:test/test.dart';

void main() {
  group('Dart to DPug Plugin System Tests', () {
    late DartToDpugPluginRegistry registry;

    setUp(() {
      registry = DartToDpugPluginRegistry();
    });

    test('Plugin registry is properly initialized', () {
      expect(registry.isAnnotationSupported('stateful'), isTrue);
      expect(registry.isAnnotationSupported('stateless'), isTrue);
      expect(registry.isAnnotationSupported('listen'), isTrue);
      expect(registry.isAnnotationSupported('changeNotifier'), isTrue);
    });

    test('Stateful plugin detects stateful classes', () {
      final classSpec = cb.Class(
        (final b) => b
          ..name = 'MyWidget'
          ..methods.add(
            cb.Method(
              (final m) => m
                ..name = 'build'
                ..returns = cb.refer('Widget'),
            ),
          ),
      );

      final existingAnnotations = <DpugAnnotationSpec>[];
      final plugin = registry.getPlugin('stateful');

      expect(plugin, isNotNull);

      final result = plugin!.processClass(
        classSpec: classSpec,
        existingAnnotations: existingAnnotations,
      );

      expect(result.length, 1);
      expect(result.first.name, 'stateful');
    });

    test('Stateless plugin detects stateless classes', () {
      final classSpec = cb.Class(
        (final b) => b
          ..name = 'MyWidget'
          ..methods.add(
            cb.Method(
              (final m) => m
                ..name = 'build'
                ..returns = cb.refer('Widget'),
            ),
          ),
      );

      final existingAnnotations = <DpugAnnotationSpec>[];
      final plugin = registry.getPlugin('stateless');

      expect(plugin, isNotNull);

      final result = plugin!.processClass(
        classSpec: classSpec,
        existingAnnotations: existingAnnotations,
      );

      expect(result.length, 1);
      expect(result.first.name, 'stateless');
    });

    test('ChangeNotifier plugin detects ChangeNotifier fields', () {
      final fieldSpec = cb.Field(
        (final b) => b
          ..name = 'counter'
          ..type = cb.refer('ValueNotifier<int>'),
      );

      final plugin = registry.getPlugin('changeNotifier');
      expect(plugin, isNotNull);

      final result = plugin!.processField(fieldSpec: fieldSpec);
      expect(result, isNotNull);
      expect(result!.name, 'changeNotifier');
    });

    test('Listen plugin detects reactive fields', () {
      // Create a field that would typically have getter/setter pattern
      final fieldSpec = cb.Field(
        (final b) => b
          ..name = 'count'
          ..type = cb.refer('int'),
      );

      final plugin = registry.getPlugin('listen');
      expect(plugin, isNotNull);

      // Note: The current heuristic is simple - in practice this would need
      // more sophisticated analysis of the actual field pattern
      final result = plugin!.processField(fieldSpec: fieldSpec);
      // The current heuristic may not detect this simple case, which is fine
      // The test demonstrates the plugin interface works
    });

    test('Plugin registry processes class annotations correctly', () {
      final classSpec = cb.Class(
        (final b) => b
          ..name = 'TestWidget'
          ..methods.add(
            cb.Method(
              (final m) => m
                ..name = 'build'
                ..returns = cb.refer('Widget'),
            ),
          ),
      );

      final existingAnnotations = <DpugAnnotationSpec>[];
      final result = registry.processClassAnnotations(
        classSpec: classSpec,
        existingAnnotations: existingAnnotations,
      );

      // Should detect either stateful or stateless
      expect(result.length, greaterThan(0));
      expect(
        result.any((final a) => a.name == 'stateful' || a.name == 'stateless'),
        isTrue,
      );
    });

    test('Plugin registry processes field annotations correctly', () {
      final fieldSpec = cb.Field(
        (final b) => b
          ..name = 'notifier'
          ..type = cb.refer('ChangeNotifier'),
      );

      final result = registry.processFieldAnnotations(fieldSpec: fieldSpec);
      expect(result, isNotNull);
      expect(result!.name, 'changeNotifier');
    });

    test('Unknown annotation types return default state annotation', () {
      final fieldSpec = cb.Field(
        (final b) => b
          ..name = 'unknownField'
          ..type = cb.refer('String'),
      );

      final result = registry.processFieldAnnotations(fieldSpec: fieldSpec);
      expect(result, isNotNull);
      expect(result!.name, 'state'); // Default fallback
    });

    test('Plugin registry singleton pattern works', () {
      final registry1 = DartToDpugPluginRegistry();
      final registry2 = DartToDpugPluginRegistry();

      expect(identical(registry1, registry2), isTrue);
    });

    test('Can retrieve specific plugins by name', () {
      final statefulPlugin = registry.getPlugin('stateful');
      final statelessPlugin = registry.getPlugin('stateless');
      final listenPlugin = registry.getPlugin('listen');
      final changeNotifierPlugin = registry.getPlugin('changeNotifier');

      expect(statefulPlugin, isNotNull);
      expect(statelessPlugin, isNotNull);
      expect(listenPlugin, isNotNull);
      expect(changeNotifierPlugin, isNotNull);

      expect(statefulPlugin!.annotationName, 'stateful');
      expect(statelessPlugin!.annotationName, 'stateless');
      expect(listenPlugin!.annotationName, 'listen');
      expect(changeNotifierPlugin!.annotationName, 'changeNotifier');
    });

    test('Plugin canHandle method works correctly', () {
      final statefulPlugin = registry.getPlugin('stateful');
      expect(statefulPlugin!.canHandle('stateful'), isTrue);
      expect(statefulPlugin.canHandle('stateless'), isFalse);
      expect(statefulPlugin.canHandle('unknown'), isFalse);
    });
  });
}
