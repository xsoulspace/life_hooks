import 'package:dpug_core/dpug_core.dart';
import 'package:test/test.dart';

void main() {
  group('CLI Integration Tests', () {
    test('DpugConverter integration works', () {
      final converter = DpugConverter();

      const dpugInput = '''
@stateful
class TestWidget
  @listen String message = 'Hello'

  Widget get build =>
    Text
      ..text: message
''';

      expect(() => converter.dpugToDart(dpugInput), returnsNormally);
      final result = converter.dpugToDart(dpugInput);
      expect(result, contains('class TestWidget'));
      expect(result, contains('extends StatefulWidget'));
    });

    test('Convert command handles real DPug syntax', () async {
      final converter = DpugConverter();

      const simpleDpug = '''
Text
  ..text: "Hello World"
''';

      final result = converter.dpugToDart(simpleDpug);
      expect(result, contains('Text'));
      expect(result, contains('text: "Hello World"'));
    });

    test('Parser validation works correctly', () {
      final converter = DpugConverter();

      // Valid DPug should not throw exception
      const validDpug = '''
@stateful
class Counter
  @listen int count = 0

  Widget get build =>
    Text
      ..text: "Hello"
''';

      expect(() => converter.dpugToDart(validDpug), returnsNormally);

      // Invalid DPug with unknown annotation should throw exception
      const invalidDpug = '''
@invalid
class Broken
  @unknown int value = 0
''';

      expect(() => converter.dpugToDart(invalidDpug), throwsException);
    });
  });
}
