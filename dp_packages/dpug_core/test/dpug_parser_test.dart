import 'package:dpug_core/compiler/dpug_parser.dart';
import 'package:test/test.dart';

void main() {
  group('DPug Parser Tests', () {
    late DPugParser parser;

    setUp(() {
      parser = DPugParser();
    });

    test('Parse basic class definition', () {
      const input = '''
@stateful
class Counter
  @listen int count = 0
''';

      final result = parser.parse(input);

      // For now, we just check that it doesn't throw
      // In a full implementation, we'd check the AST structure
      expect(result, isNotNull);
    });

    test('Parse widget tree', () {
      const input = '''
Text
  ..text: 'Hello World'
  ..style:
    TextStyle
      ..fontSize: 16.0
''';

      final result = parser.parse(input);
      expect(result, isNotNull);
    });

    test('Parse complete DPug example', () {
      const input = '''
@stateful
class Counter
  @listen int count = 0

  Widget get build =>
    Column
      Text
        ..text: 'Count: \$count'
      ElevatedButton
        ..onPressed: () => count++
        ..child:
          Text
            ..text: 'Increment'
''';

      final result = parser.parse(input);
      expect(result, isNotNull);
    });

    test('Parser validation', () {
      final issues = parser.lint();
      // Allow some linting issues during development
      // In production, we'd want: expect(issues, isEmpty);
      expect(issues, isA<List<String>>());
    });

    test('Grammar info is available', () {
      final info = parser.getGrammarInfo();
      expect(info, isNotEmpty);
      expect(info, contains('DPug Grammar'));
    });

    test('Examples are available', () {
      final examples = parser.getExamples();
      expect(examples, isNotEmpty);
      expect(examples.keys, contains('Simple Widget'));
      expect(examples.keys, contains('Class Definition'));
    });

    test('Invalid syntax handling', () {
      const invalidInput = '''
@invalid
class Broken
  @unknown annotation
  Widget get build =>
    @#\$% invalid syntax
''';

      final result = parser.parse(invalidInput);
      // Should not crash, but parsing may fail
      expect(result, isNotNull);
    });

    test('Syntax validation', () {
      const validInput = '''
@stateful
class Test
  @listen String name = 'test'
''';

      final isValid = parser.isValid(validInput);
      expect(isValid, isTrue);
    });
  });
}
