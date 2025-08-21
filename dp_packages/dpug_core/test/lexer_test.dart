import 'package:dpug_core/dpug_core.dart';
import 'package:test/test.dart';

void main() {
  group('DartPug Lexer', () {
    test('tokenizes basic widget declaration', () {
      const input = '''
Column
  TextField
    value: newTodo
    onChanged: (value) => newTodo = value
''';
      final lexer = Lexer(input);
      final tokens = lexer.tokenize();

      expect(
        tokens,
        containsAllInOrder([
          isA<Token>()
              .having((final t) => t.type, 'type', TokenType.identifier)
              .having((final t) => t.value, 'value', 'Column'),
          isA<Token>().having((final t) => t.type, 'type', TokenType.indent),
          isA<Token>()
              .having((final t) => t.type, 'type', TokenType.identifier)
              .having((final t) => t.value, 'value', 'TextField'),
          // ... continue with other expected tokens
        ]),
      );
    });

    test('handles state annotations', () {
      const input = '''
@stateful
class TodoList {
  @listen List<Todo> todos = [];
}''';
      final lexer = Lexer(input);
      final tokens = lexer.tokenize();

      expect(
        tokens,
        containsAllInOrder([
          isA<Token>()
              .having((final t) => t.type, 'type', TokenType.annotation)
              .having((final t) => t.value, 'value', '@stateful'),
          isA<Token>()
              .having((final t) => t.type, 'type', TokenType.keyword)
              .having((final t) => t.value, 'value', 'class'),
          // ... continue with other expected tokens
        ]),
      );
    });
  });
}
