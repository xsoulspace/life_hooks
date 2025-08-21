import 'package:dpug_core/dpug_core.dart';
import 'package:test/test.dart';

void main() {
  group('DPug positional and cascade arguments', () {
    test("supports cascade positional argument ..'Hello'", () {
      const input = '''
@stateful
class A
  Widget get build =>
    Column
      Text
        ..'Hello'
''';

      final out = DpugConverter().dpugToDart(input);
      expect(out, contains('Text("Hello")'));
    });

    test("supports function-style positional: Text('World')", () {
      const input = '''
@stateful
class A
  Widget get build =>
    Column
      Text("World")
''';

      final out = DpugConverter().dpugToDart(input);
      expect(out, contains('Text("World")'));
    });

    test('mix of cascade and function-style in children', () {
      const input = '''
@stateful
class A
  Widget get build =>
    Column
      Text
        ..'Hello'
      Text("World")
''';

      final out = DpugConverter().dpugToDart(input);
      expect(out, contains('Text("Hello")'));
      expect(out, contains('Text("World")'));
    });
  });
}
