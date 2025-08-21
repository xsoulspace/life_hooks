import 'package:dpug_code_builder/dpug_code_builder.dart';
import 'package:test/test.dart';

void main() {
  group('DPug Code Builder Tests', () {
    test('Create state field specification', () {
      final fieldSpec = DpugStateFieldSpec(
        name: 'count',
        type: 'int',
        annotation: const DpugAnnotationSpec(name: 'listen'),
        initializer: DpugExpressionSpec.reference('0'),
      );

      expect(fieldSpec.name, equals('count'));
      expect(fieldSpec.type, equals('int'));
      expect(fieldSpec.annotation.name, equals('listen'));
      expect(fieldSpec.initializer, isNotNull);
    });

    test('Create method specification', () {
      final methodSpec = DpugMethodSpec.getter(
        name: 'build',
        returnType: 'Widget',
        body: DpugCodeSpec('return Text("Hello");'),
      );

      expect(methodSpec.name, equals('build'));
      expect(methodSpec.returnType, equals('Widget'));
      expect(methodSpec.body.code, contains('return Text("Hello");'));
    });

    test('Create class specification', () {
      final classSpec = DpugClassSpec(
        name: 'TestWidget',
        stateFields: [
          DpugStateFieldSpec(
            name: 'message',
            type: 'String',
            annotation: const DpugAnnotationSpec(name: 'listen'),
            initializer: DpugExpressionSpec.reference('"Hello"'),
          ),
        ],
        methods: [
          DpugMethodSpec.getter(
            name: 'build',
            returnType: 'Widget',
            body: DpugCodeSpec('return Text(message);'),
          ),
        ],
      );

      expect(classSpec.name, equals('TestWidget'));
      expect(classSpec.stateFields.length, equals(1));
      expect(classSpec.methods.length, equals(1));
    });

    test('Generate StatefulWidget code', () {
      final classSpec = DpugClassSpec(
        name: 'Counter',
        stateFields: [
          DpugStateFieldSpec(
            name: 'count',
            type: 'int',
            annotation: const DpugAnnotationSpec(name: 'listen'),
            initializer: DpugExpressionSpec.reference('0'),
          ),
        ],
        methods: [
          DpugMethodSpec.getter(
            name: 'build',
            returnType: 'Widget',
            body: DpugCodeSpec(r'return Text("Count: $count");'),
          ),
        ],
      );

      final generator = DartWidgetCodeGenerator();
      final code = generator.generateStatefulWidget(classSpec);

      expect(code, contains('class Counter extends StatefulWidget'));
      expect(code, contains('class _CounterState extends State<Counter>'));
      expect(code, contains('late int _count = widget.count'));
      expect(code, contains('int get count => _count'));
      expect(
        code,
        contains('set count(int value) => setState(() => _count = value)'),
      );
      expect(code, contains(r'Text("Count: $count")'));
    });

    test('Annotation specification', () {
      const annotation = DpugAnnotationSpec(name: 'stateful');
      expect(annotation.name, equals('stateful'));
    });

    test('Code specification', () {
      final code = DpugCodeSpec('return null;');
      expect(code.code, equals('return null;'));
    });

    test('Expression specification', () {
      final expr = DpugExpressionSpec.reference('someValue');
      expect(expr, isNotNull);
    });
  });
}
