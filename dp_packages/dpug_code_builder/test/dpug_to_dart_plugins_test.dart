import 'package:code_builder/code_builder.dart' as cb;
import 'package:dpug_code_builder/src/specs/specs.dart';
import 'package:dpug_code_builder/src/visitors/dpug_to_dart_plugins.dart';
import 'package:test/test.dart';

void main() {
  group('DPug to Dart Plugin System Tests', () {
    late DpugToDartPluginRegistry registry;

    setUp(() {
      registry = DpugToDartPluginRegistry();
    });

    test('Plugin registry is properly initialized', () {
      expect(registry.isAnnotationSupported('stateful'), isTrue);
      expect(registry.isAnnotationSupported('stateless'), isTrue);
      expect(registry.isAnnotationSupported('listen'), isTrue);
      expect(registry.isAnnotationSupported('changeNotifier'), isTrue);
    });

    test('Stateful plugin generates stateful widget marker', () {
      final classSpec = DpugClassSpec(
        name: 'MyWidget',
        annotations: [DpugAnnotationSpec.stateful()],
        stateFields: [],
        methods: [],
      );

      final context = <String, dynamic>{};
      final result = registry.generateClassCode(
        classSpec: classSpec,
        context: context,
      );

      expect(result, isNotNull);
      expect(result is cb.Code, isTrue);
      expect(
        result!.accept(cb.DartEmitter()).toString(),
        '__STATEFUL_WIDGET__',
      );
    });

    test('Stateless plugin generates stateless widget marker', () {
      final classSpec = DpugClassSpec(
        name: 'MyWidget',
        annotations: [DpugAnnotationSpec.stateless()],
        stateFields: [],
        methods: [],
      );

      final context = <String, dynamic>{};
      final result = registry.generateClassCode(
        classSpec: classSpec,
        context: context,
      );

      expect(result, isNotNull);
      expect(result is cb.Code, isTrue);
      expect(
        result!.accept(cb.DartEmitter()).toString(),
        '__STATELESS_WIDGET__',
      );
    });

    test('Listen plugin generates reactive field code', () {
      final fieldSpec = DpugStateFieldSpec(
        name: 'count',
        type: 'int',
        annotation: DpugAnnotationSpec.listen(),
      );

      final context = <String, dynamic>{'isStateClass': true};
      final result = registry.generateFieldCode(
        fieldSpec: fieldSpec,
        context: context,
      );

      expect(result, isNotNull);
      expect(result is cb.Field, isTrue);
      final field = result! as cb.Field;
      expect(field.name, '_count');
      expect(field.modifier, cb.FieldModifier.var$);
    });

    test('ChangeNotifier plugin generates ChangeNotifier field code', () {
      final fieldSpec = DpugStateFieldSpec(
        name: 'notifier',
        type: 'ValueNotifier<int>',
        annotation: DpugAnnotationSpec.changeNotifier(),
      );

      final context = <String, dynamic>{'isStateClass': true};
      final result = registry.generateFieldCode(
        fieldSpec: fieldSpec,
        context: context,
      );

      expect(result, isNotNull);
      expect(result is cb.Field, isTrue);
      final field = result! as cb.Field;
      expect(field.name, '_notifierNotifier');
      expect(field.modifier, cb.FieldModifier.final$);
    });

    test('Field plugins return widget class fields for non-state classes', () {
      final fieldSpec = DpugStateFieldSpec(
        name: 'count',
        type: 'int',
        annotation: DpugAnnotationSpec.listen(),
      );

      final context = <String, dynamic>{'isStateClass': false};
      final result = registry.generateFieldCode(
        fieldSpec: fieldSpec,
        context: context,
      );

      expect(result, isNotNull);
      expect(result is cb.Field, isTrue);
      final field = result! as cb.Field;
      expect(field.name, 'count');
      expect(field.modifier, cb.FieldModifier.final$);
    });

    test('Plugin registry returns null for unsupported class annotations', () {
      final classSpec = DpugClassSpec(
        name: 'MyWidget',
        annotations: [const DpugAnnotationSpec(name: 'unknown')],
        stateFields: [],
        methods: [],
      );

      final context = <String, dynamic>{};
      final result = registry.generateClassCode(
        classSpec: classSpec,
        context: context,
      );

      expect(result, isNull);
    });

    test('Plugin registry returns null for unsupported field annotations', () {
      final fieldSpec = DpugStateFieldSpec(
        name: 'unknown',
        type: 'String',
        annotation: const DpugAnnotationSpec(name: 'unknown'),
      );

      final context = <String, dynamic>{'isStateClass': true};
      final result = registry.generateFieldCode(
        fieldSpec: fieldSpec,
        context: context,
      );

      expect(result, isNull);
    });

    test('Plugin registry singleton pattern works', () {
      final registry1 = DpugToDartPluginRegistry();
      final registry2 = DpugToDartPluginRegistry();

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

    test('Multiple class annotations are handled in order', () {
      final classSpec = DpugClassSpec(
        name: 'MyWidget',
        annotations: [
          DpugAnnotationSpec.stateful(),
          DpugAnnotationSpec.stateless(),
        ],
        stateFields: [],
        methods: [],
      );

      final context = <String, dynamic>{};
      final result = registry.generateClassCode(
        classSpec: classSpec,
        context: context,
      );

      // Should handle stateful first (first in the list)
      expect(result, isNotNull);
      expect(
        result!.accept(cb.DartEmitter()).toString(),
        '__STATEFUL_WIDGET__',
      );
    });
  });
}
