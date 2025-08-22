import 'package:code_builder/code_builder.dart' as cb;
import 'package:dpug_core/compiler/plugins/annotation_plugins.dart';
import 'package:dpug_core/dpug_core.dart';
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
