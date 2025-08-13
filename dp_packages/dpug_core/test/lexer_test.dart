import 'package:dpug_core/dpug_core.dart';
import 'package:test/test.dart';

void main() {
  group('DartPug Lexer', () {
    test('tokenizes basic widget declaration', () {
      final input = '''
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
              .having((t) => t.type, 'type', TokenType.identifier)
              .having((t) => t.value, 'value', 'Column'),
          isA<Token>().having((t) => t.type, 'type', TokenType.indent),
          isA<Token>()
              .having((t) => t.type, 'type', TokenType.identifier)
              .having((t) => t.value, 'value', 'TextField'),
          // ... continue with other expected tokens
        ]),
      );
    });

    test('handles state annotations', () {
      final input = '''
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
              .having((t) => t.type, 'type', TokenType.annotation)
              .having((t) => t.value, 'value', '@stateful'),
          isA<Token>()
              .having((t) => t.type, 'type', TokenType.keyword)
              .having((t) => t.value, 'value', 'class'),
          // ... continue with other expected tokens
        ]),
      );
    });
  });
}
