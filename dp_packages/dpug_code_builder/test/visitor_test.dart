import 'package:code_builder/code_builder.dart' as cb;
import 'package:dpug_code_builder/dpug_code_builder.dart';
import 'package:test/test.dart';

void main() {
  group('Visitor Chain Tests', () {
    group('DPUG -> Dart -> DPUG Conversion', () {
      test('Simple stateful widget', () {
        // Create initial DPUG spec
        final dpugSpec =
            (Dpug.classBuilder()
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
        final dartSpec = Dpug.toDart(dpugSpec);

        // Test Dart -> DPUG conversion
        final convertedDpugSpec = Dpug.fromDart(dartSpec);
        expect(convertedDpugSpec, isNotNull);

        // Verify string representations
        final originalDpugString = Dpug.emitDpug(dpugSpec);
        final convertedDpugString = Dpug.emitDpug(convertedDpugSpec!);

        expect(originalDpugString, equals(expectedDpugCode));
        expect(convertedDpugString, equals(expectedDpugCode));

        // Verify round-trip conversion
        final roundTripDartSpec = Dpug.toDart(convertedDpugSpec);
        expect(roundTripDartSpec.toString(), equals(dartSpec.toString()));
      });

      test('Widget with properties and callbacks', () {
        final dpugSpec =
            (Dpug.widgetBuilder()
                  ..name('ElevatedButton')
                  ..property(
                    'onPressed',
                    DpugExpressionSpec.reference(
                      '() => setState(() => count++)',
                    ),
                  )
                  ..child(
                    DpugWidgetBuilder()
                      ..name('Text')
                      ..positionalCascadeArgument(
                        DpugExpressionSpec.string('Increment'),
                      ),
                  ))
                .build();

        const expectedDpugCode = '''
ElevatedButton
  ..onPressed: () => setState(() => count++)
  Text
    ..'Increment\'''';

        // Test full conversion chain
        final dartSpec = Dpug.toDart(dpugSpec);
        final convertedDpugSpec = Dpug.fromDart(dartSpec);
        expect(convertedDpugSpec, isNotNull);

        final originalDpugString = Dpug.emitDpug(dpugSpec);
        final convertedDpugString = Dpug.emitDpug(convertedDpugSpec!);

        expect(originalDpugString, equals(expectedDpugCode));
        expect(convertedDpugString, equals(expectedDpugCode));
      });
    });

    group('Dart -> DPUG Conversion', () {
      test('Convert Dart class to DPUG', () {
        final dartClass = cb.Class(
          (final b) => b
            ..name = 'MyWidget'
            ..extend = cb.refer('StatefulWidget')
            ..methods.add(
              cb.Method(
                (final b) => b
                  ..name = 'build'
                  ..returns = cb.refer('Widget')
                  ..body = const cb.Code('''
              return Column(
                children: [
                  Text('Hello'),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: Text('Click me'),
                  ),
                ],
              );
            '''),
              ),
            ),
        );

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
        final dpugSpec = Dpug.fromDart(dartClass);
        expect(dpugSpec, isNotNull);

        // Verify string representation
        final dpugString = Dpug.emitDpug(dpugSpec!);
        expect(dpugString, equals(expectedDpugCode));

        // Verify round-trip conversion
        final roundTripDartSpec = Dpug.toDart(dpugSpec);
        expect(roundTripDartSpec.toString(), equals(dartClass.toString()));
      });

      test('Convert Dart method to DPUG', () {
        final dartMethod = cb.Method(
          (final b) => b
            ..name = 'build'
            ..returns = cb.refer('Widget')
            ..body = const cb.Code('''
            return Container(
              padding: EdgeInsets.all(16),
              child: Text('Hello'),
            );
          '''),
        );

        const expectedDpugCode = '''
Widget get build =>
  Container
    ..padding: EdgeInsets.all(16)
    Text
      ..'Hello\'''';

        // Test conversion chain
        final dpugSpec = Dpug.fromDart(dartMethod);
        expect(dpugSpec, isNotNull);

        final dpugString = Dpug.emitDpug(dpugSpec!);
        expect(dpugString, equals(expectedDpugCode));

        // Verify round-trip
        final roundTripDartSpec = Dpug.toDart(dpugSpec);
        expect(roundTripDartSpec.toString(), equals(dartMethod.toString()));
      });
    });
  });
}
