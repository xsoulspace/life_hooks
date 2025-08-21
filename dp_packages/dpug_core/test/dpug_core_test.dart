import 'package:dpug_core/dpug_core.dart';
import 'package:test/test.dart';

void main() {
  group('DPug Core Tests', () {
    final converter = DpugConverter();

    test('Basic DPug to Dart conversion', () {
      const dpugCode = r'''
@stateful
class Counter
  @listen int count = 0

  Widget get build =>
    Text
      ..text: 'Count: $count'
''';

      final dartCode = converter.dpugToDart(dpugCode);

      expect(dartCode, contains('class Counter extends StatefulWidget'));
      expect(dartCode, contains('late int _count = widget.count'));
      expect(dartCode, contains('int get count => _count'));
      expect(
        dartCode,
        contains('set count(int value) => setState(() => _count = value)'),
      );
      expect(dartCode, contains('Text('));
      expect(dartCode, contains(r"'Count: $count'"));
    });

    test('Basic Dart to DPug conversion', () {
      const dartCode = r'''
class Counter extends StatefulWidget {
  const Counter({required this.count, super.key});
  final int count;

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  late int _count = widget.count;
  int get count => _count;
  set count(int value) => setState(() => _count = value);

  @override
  Widget build(BuildContext context) {
    return Text('Count: $count');
  }
}
''';

      final dpugCode = converter.dartToDpug(dartCode);

      expect(dpugCode, contains('@stateful'));
      expect(dpugCode, contains('class Counter'));
      expect(dpugCode, contains('@listen int count = 0'));
      expect(dpugCode, contains('Widget get build'));
      expect(dpugCode, contains('Text'));
      expect(dpugCode, contains(r"..text: 'Count: $count'"));
    });

    test('Round-trip conversion preserves semantics', () {
      const originalDpug = '''
@stateful
class TestWidget
  @listen String message = 'Hello'

  Widget get build =>
    Column
      Text
        ..text: message
      ElevatedButton
        ..onPressed: () => message = 'World'
''';

      final dartCode = converter.dpugToDart(originalDpug);
      final convertedBack = converter.dartToDpug(dartCode);

      // Check that essential structure is preserved
      expect(convertedBack, contains('@stateful'));
      expect(convertedBack, contains('class TestWidget'));
      expect(convertedBack, contains('@listen String message'));
      expect(convertedBack, contains('Column'));
      expect(convertedBack, contains('Text'));
      expect(convertedBack, contains('ElevatedButton'));
    });

    test('Error handling for invalid DPug', () {
      const invalidDpug = '''
@invalid
class Broken
  @broken what is this
  Widget get build =>
    UnknownWidget
      ..invalid: property
''';

      expect(
        () => converter.dpugToDart(invalidDpug),
        throwsA(isA<Exception>()),
      );
    });

    test('Error handling for invalid Dart', () {
      const invalidDart = '''
class Broken extends NotAWidget {
  void notABuildMethod() {
    return null;
  }
}
''';

      expect(
        () => converter.dartToDpug(invalidDart),
        throwsA(isA<Exception>()),
      );
    });
  });
}
