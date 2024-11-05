import 'package:code_builder/code_builder.dart' as cb;
import 'package:dpug/dpug.dart';
import 'package:test/test.dart';

void main() {
  group('Visitor Chain Tests', () {
    group('DPUG -> Dart -> DPUG Conversion', () {
      test('Simple stateful widget', () {
        // Create initial DPUG spec
        final dpugSpec = (Dpug.classBuilder()
              ..name('Counter')
              ..annotation(DpugAnnotationSpec.stateful())
              ..listenField(
                name: 'count',
                type: 'int',
                initializer: DpugExpressionSpec.reference('0'),
              )
              ..buildMethod(
                body: WidgetHelpers.column(
                  children: [
                    DpugWidgetBuilder()
                      ..name('Text')
                      ..positionalCascadeArgument(
                        DpugExpressionSpec.reference('count.toString()'),
                      ),
                  ],
                ),
              ))
            .build();

        const expectedDpugCode = '''
@stateful
class Counter
  @listen int count = 0

  Widget get build =>
    Column
      Text
        ..count.toString()''';

        // Test DPUG -> Dart conversion
        final dartSpec = Dpug.dpugToDart(dpugSpec);
        final dartString = Dpug.generateDartStringFromDpug(dpugSpec);

        // Test Dart -> DPUG conversion
        final convertedDpugSpec = Dpug.dartToDpug(dartSpec);
        expect(convertedDpugSpec, isNotNull);

        // Verify string representations
        final originalDpugString = Dpug.generateDpugString(dpugSpec);
        final convertedDpugString = Dpug.generateDpugString(convertedDpugSpec!);

        expect(originalDpugString, equals(expectedDpugCode));
        expect(convertedDpugString, equals(expectedDpugCode));

        // Verify round-trip conversion
        final roundTripDartSpec = Dpug.dpugToDart(convertedDpugSpec);
        expect(roundTripDartSpec.toString(), equals(dartSpec.toString()));
      });

      test('Widget with properties and callbacks', () {
        final dpugSpec = (Dpug.widgetBuilder()
              ..name('ElevatedButton')
              ..property(
                'onPressed',
                DpugExpressionSpec.reference('() => setState(() => count++)'),
              )
              ..child(DpugWidgetBuilder()
                ..name('Text')
                ..positionalCascadeArgument(
                  DpugExpressionSpec.stringLiteral('Increment'),
                )))
            .build();

        const expectedDpugCode = '''
ElevatedButton
  ..onPressed: () => setState(() => count++)
  Text
    ..'Increment\'''';

        // Test full conversion chain
        final dartSpec = Dpug.dpugToDart(dpugSpec);
        final convertedDpugSpec = Dpug.dartToDpug(dartSpec);
        expect(convertedDpugSpec, isNotNull);

        final originalDpugString = Dpug.generateDpugString(dpugSpec);
        final convertedDpugString = Dpug.generateDpugString(convertedDpugSpec!);

        expect(originalDpugString, equals(expectedDpugCode));
        expect(convertedDpugString, equals(expectedDpugCode));
      });
    });

    group('Dart -> DPUG Conversion', () {
      test('Convert Dart class to DPUG', () {
        final dartClass = cb.Class((b) => b
          ..name = 'MyWidget'
          ..extend = cb.refer('StatefulWidget')
          ..methods.add(cb.Method((b) => b
            ..name = 'build'
            ..returns = cb.refer('Widget')
            ..body = cb.Code('''
              return Column(
                children: [
                  Text('Hello'),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: Text('Click me'),
                  ),
                ],
              );
            '''))));

        const expectedDpugCode = '''
@stateful
class MyWidget
  Widget get build =>
    Column
      Text
        ..'Hello'
      ElevatedButton
        ..onPressed: () => setState(() {})
        Text
          ..'Click me\'''';

        // Test Dart -> DPUG conversion
        final dpugSpec = Dpug.dartToDpug(dartClass);
        expect(dpugSpec, isNotNull);

        // Verify string representation
        final dpugString = Dpug.generateDpugString(dpugSpec!);
        expect(dpugString, equals(expectedDpugCode));

        // Verify round-trip conversion
        final roundTripDartSpec = Dpug.dpugToDart(dpugSpec);
        expect(roundTripDartSpec.toString(), equals(dartClass.toString()));
      });

      test('Convert Dart method to DPUG', () {
        final dartMethod = cb.Method((b) => b
          ..name = 'build'
          ..returns = cb.refer('Widget')
          ..body = cb.Code('''
            return Container(
              padding: EdgeInsets.all(16),
              child: Text('Hello'),
            );
          '''));

        const expectedDpugCode = '''
Widget get build =>
  Container
    ..padding: EdgeInsets.all(16)
    Text
      ..'Hello\'''';

        // Test conversion chain
        final dpugSpec = Dpug.dartToDpug(dartMethod);
        expect(dpugSpec, isNotNull);

        final dpugString = Dpug.generateDpugString(dpugSpec!);
        expect(dpugString, equals(expectedDpugCode));

        // Verify round-trip
        final roundTripDartSpec = Dpug.dpugToDart(dpugSpec);
        expect(roundTripDartSpec.toString(), equals(dartMethod.toString()));
      });
    });
  });
}
