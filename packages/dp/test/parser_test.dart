import 'package:dpug_analyzer/compiler/parser.dart';
import 'package:test/test.dart';

void main() {
  group('DPugParser', () {
    late DPugParser parser;

    setUp(() {
      parser = DPugParser();
    });

    test('processes empty file', () async {
      final output = await parser.processDPugFile('', null);
      expect(output, contains('class'));
      expect(output, contains('Widget build'));
    });

    test('processes stateful widget', () async {
      final input = '''
@stateful
class TodoList {
  @listen List<Todo> todos = [];
  @state String query = '';

  Widget get build =>
    Column
      TextField
        value: newTodo
}''';

      final output = await parser.processDPugFile(input, null);

      expect(output, contains('class TodoList extends StatefulWidget'));
      expect(output, contains('class _TodoListState extends State<TodoList>'));
      expect(output, contains('List<Todo> _todos'));
      expect(output, contains('String _query'));
    });

    test('validates state variables', () async {
      final input = '''
@stateful
class TodoList {
  @state query;  // Missing type
}''';

      expect(
        () => parser.processDPugFile(input, null),
        throwsA(isA<ParserError>().having(
          (e) => e.message,
          'message',
          contains('must have a type'),
        )),
      );
    });

    test('validates build method', () async {
      final input = '''
@stateful
class TodoList {
  @state String query = '';
  // Missing build method
}''';

      expect(
        () => parser.processDPugFile(input, null),
        throwsA(isA<ParserError>().having(
          (e) => e.message,
          'message',
          contains('must have a build method'),
        )),
      );
    });

    test('tracks source locations', () async {
      final input = '''
@stateful
class TodoList {
  @state String query = '';
}''';

      await parser.processDPugFile(input, null);

      final location = parser.sourceMapper.getOriginalLocation(0);
      expect(location, isNotNull);
      expect(location!.line, equals(1));
      expect(location.column, equals(1));
    });

    test('handles syntax errors', () async {
      final input = '''
@stateful
class TodoList {
  @state String query = // Missing value
}''';

      expect(
        () => parser.processDPugFile(input, null),
        throwsA(isA<ParserError>()),
      );
    });
  });
}
