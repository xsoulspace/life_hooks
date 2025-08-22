import 'package:code_builder/code_builder.dart' as cb;
import 'package:dpug_core/compiler/plugins/annotation_plugins.dart';
import 'package:dpug_core/dpug_core.dart';
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';

void main() {
  group('Plugin System Tests', () {
    late AnnotationPluginRegistry registry;

    setUp(() {
      registry = AnnotationPluginRegistry();
    });

    test('Built-in plugins are registered', () {
      expect(registry.isAnnotationSupported('stateful'), isTrue);
      expect(registry.isAnnotationSupported('listen'), isTrue);
    });

    test('Custom plugins can be registered', () {
      final customPlugin = TestPlugin();
      registry.registerPlugin(customPlugin);

      expect(registry.isAnnotationSupported('test'), isTrue);
    });

    test('Unknown annotations are not supported by default', () {
      expect(registry.isAnnotationSupported('unknown'), isFalse);
    });

    test('Plugin registry is singleton', () {
      final registry1 = AnnotationPluginRegistry();
      final registry2 = AnnotationPluginRegistry();

      expect(identical(registry1, registry2), isTrue);
    });

    test('Can retrieve plugin by name', () {
      final plugin = registry.getPlugin('stateful');
      expect(plugin, isNotNull);
      expect(plugin!.annotationName, equals('stateful'));
    });

    test('Unknown plugin returns null', () {
      final plugin = registry.getPlugin('unknown');
      expect(plugin, isNull);
    });

    test('Test plugin interface', () {
      final plugin = TestPlugin();
      expect(plugin.annotationName, equals('test'));
      expect(plugin.canHandle('test'), isTrue);
      expect(plugin.canHandle('other'), isFalse);
    });

    test('Plugin registry processes class annotations', () {
      final registry = AnnotationPluginRegistry();
      final classNode = ClassNode(
        name: 'TestClass',
        annotations: ['stateful'],
        stateVariables: [],
        methods: [],
        span: FileSpan('', 0, 0, 0, 0),
      );

      // This should not throw an error
      registry.processClassAnnotation(
        annotationName: 'stateful',
        classNode: classNode,
      );

      expect(true, isTrue); // Just verify no exception was thrown
    });

    test('Plugin registry processes field annotations', () {
      final registry = AnnotationPluginRegistry();
      final field = StateVariable(
        name: 'testField',
        type: 'int',
        annotation: 'listen',
      );
      final classNode = ClassNode(
        name: 'TestClass',
        annotations: [],
        stateVariables: [field],
        methods: [],
        span: FileSpan('', 0, 0, 0, 0),
      );

      // This should not throw an error
      registry.processFieldAnnotation(
        annotationName: 'listen',
        field: field,
        classNode: classNode,
      );

      expect(true, isTrue); // Just verify no exception was thrown
    });

    test('Unknown annotations are handled gracefully', () {
      final registry = AnnotationPluginRegistry();
      final classNode = ClassNode(
        name: 'TestClass',
        annotations: ['unknown'],
        stateVariables: [],
        methods: [],
        span: FileSpan('', 0, 0, 0, 0),
      );

      // This should not throw an error even for unknown annotations
      registry.processClassAnnotation(
        annotationName: 'unknown',
        classNode: classNode,
      );

      expect(true, isTrue); // Just verify no exception was thrown
    });
  });
}

/// Test plugin for testing purposes
class TestPlugin implements AnnotationPlugin {
  @override
  String get annotationName => 'test';

  @override
  bool canHandle(final String annotationName) =>
      annotationName == this.annotationName;

  @override
  void processClassAnnotation({
    required final String annotationName,
    required final ClassNode classNode,
    required final DpugConverter converter,
  }) {}

  @override
  void processFieldAnnotation({
    required final String annotationName,
    required final StateVariable field,
    required final ClassNode classNode,
    required final DpugConverter converter,
  }) {}

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
  }) => null;
}
