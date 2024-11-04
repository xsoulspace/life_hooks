import 'package:dpug_analyzer/compiler/lexer.dart';
import 'package:test/test.dart';

void main() {
  group('DPugLexer', () {
    test('handles empty input', () {
      final lexer = DPugLexer('');
      final tokens = lexer.tokenize();
      expect(tokens.length, 1);
      expect(tokens[0].type, TokenType.eof);
    });

    test('handles basic class declaration', () {
      final input = '''
@stateful
class TodoList {
}''';
      final lexer = DPugLexer(input);
      final tokens = lexer.tokenize();

      expect(
          tokens.map((t) => t.type),
          equals([
            TokenType.stateful,
            TokenType.newLine,
            TokenType.className,
            TokenType.identifier,
            TokenType.braceLeft,
            TokenType.newLine,
            TokenType.braceRight,
            TokenType.eof,
          ]));
    });
    test('handles state declarations', () {
      final input = '''
  @listen List<Todo> todos = [];
  @state String searchQuery = '';
''';
      final lexer = DPugLexer(input);
      final tokens = lexer.tokenize();

      expect(
          tokens.map((t) => t.type),
          equals([
            TokenType.listen,
            TokenType.identifier, // List
            TokenType.genericLeft, // <
            TokenType.identifier, // Todo
            TokenType.genericRight, // >
            TokenType.identifier, // todos
            TokenType.equals,
            TokenType.blockStart,
            TokenType.blockEnd,
            TokenType.newLine,
            TokenType.state,
            TokenType.identifier, // String
            TokenType.identifier, // searchQuery
            TokenType.equals,
            TokenType.string,
            TokenType.eof,
          ]));
    });

    test('handles build method declaration', () {
      final input = '''
  Widget get build =>
    Column
      TextField
        value: newTodo
''';
      final lexer = DPugLexer(input);
      final tokens = lexer.tokenize();

      expect(
          tokens.map((t) => t.type),
          equals([
            TokenType.widget,
            TokenType.get,
            TokenType.build,
            TokenType.arrow,
            TokenType.newLine,
            TokenType.indent,
            TokenType.identifier,
            TokenType.newLine,
            TokenType.indent,
            TokenType.identifier,
            TokenType.newLine,
            TokenType.indent,
            TokenType.identifier,
            TokenType.colon,
            TokenType.identifier,
            TokenType.newLine,
            TokenType.eof,
          ]));
    });

    test('handles cascade operator', () {
      final input = '..padding(16)';
      final lexer = DPugLexer(input);
      final tokens = lexer.tokenize();

      expect(
          tokens.map((t) => t.type),
          equals([
            TokenType.cascade,
            TokenType.identifier,
            TokenType.parenthesisLeft,
            TokenType.number,
            TokenType.parenthesisRight,
            TokenType.eof,
          ]));
    });

    test('handles indentation correctly', () {
      final input = '''
Column
  TextField
    value: newTodo
  Button
    "Add Todo"
''';
      final lexer = DPugLexer(input);
      final tokens = lexer.tokenize();

      var indentLevel = 0;
      for (final token in tokens) {
        if (token.type == TokenType.indent) indentLevel++;
        if (token.type == TokenType.dedent) indentLevel--;
      }
      expect(indentLevel, equals(0),
          reason: 'Indentation levels should balance');
    });

    test('handles state declarations with generics', () {
      final input = '@listen List<Todo> todos = [];';
      final lexer = DPugLexer(input);
      final tokens = lexer.tokenize();

      expect(
          tokens.map((t) => t.type),
          equals([
            TokenType.listen,
            TokenType.identifier, // List
            TokenType.genericLeft,
            TokenType.identifier, // Todo
            TokenType.genericRight,
            TokenType.identifier, // todos
            TokenType.equals,
            TokenType.blockStart,
            TokenType.blockEnd,
            TokenType.eof,
          ]));
    });

    test('handles method chains', () {
      final input = '''
TextField
  value: newTodo
  onChanged: (value) => newTodo = value
..padding(16)''';
      final lexer = DPugLexer(input);
      final tokens = lexer.tokenize();

      expect(
          tokens.map((t) => t.type),
          equals([
            TokenType.identifier, // TextField
            TokenType.newLine,
            TokenType.indent,
            TokenType.identifier, // value
            TokenType.colon,
            TokenType.identifier, // newTodo
            TokenType.newLine,
            TokenType.indent,
            TokenType.identifier, // onChanged
            TokenType.colon,
            TokenType.parenthesisLeft,
            TokenType.identifier, // value
            TokenType.parenthesisRight,
            TokenType.arrow,
            TokenType.identifier, // newTodo
            TokenType.equals,
            TokenType.identifier, // value
            TokenType.newLine,
            TokenType.cascade,
            TokenType.identifier, // padding
            TokenType.parenthesisLeft,
            TokenType.number, // 16
            TokenType.parenthesisRight,
            TokenType.eof,
          ]));
    });

    test('handles block expressions', () {
      final input = '''
action: () {
  todos.add(Todo(newTodo));
  newTodo = '';
}''';
      final lexer = DPugLexer(input);
      final tokens = lexer.tokenize();

      expect(
          tokens.map((t) => t.type),
          equals([
            TokenType.identifier, // action
            TokenType.colon,
            TokenType.parenthesisLeft,
            TokenType.parenthesisRight,
            TokenType.braceLeft,
            TokenType.newLine,
            TokenType.indent,
            TokenType.identifier, // todos
            TokenType.dot,
            TokenType.identifier, // add
            TokenType.parenthesisLeft,
            TokenType.identifier, // Todo
            TokenType.parenthesisLeft,
            TokenType.identifier, // newTodo
            TokenType.parenthesisRight,
            TokenType.parenthesisRight,
            TokenType.newLine,
            TokenType.indent,
            TokenType.identifier, // newTodo
            TokenType.equals,
            TokenType.string, // ''
            TokenType.braceRight,
            TokenType.eof,
          ]));
    });

    test('handles complex widget tree with indentation', () {
      final input = '''
ListView.builder
  itemCount: todos.length
  itemBuilder: (context, index) =>
    ListTile
      title: Text(todo.title)''';
      final lexer = DPugLexer(input);
      final tokens = lexer.tokenize();

      expect(
          tokens.map((t) => t.type),
          equals([
            TokenType.identifier, // ListView
            TokenType.dot,
            TokenType.identifier, // builder
            TokenType.newLine,
            TokenType.indent,
            TokenType.identifier, // itemCount
            TokenType.colon,
            TokenType.identifier, // todos
            TokenType.dot,
            TokenType.identifier, // length
            TokenType.newLine,
            TokenType.indent,
            TokenType.identifier, // itemBuilder
            TokenType.colon,
            TokenType.parenthesisLeft,
            TokenType.identifier, // context
            TokenType.comma,
            TokenType.identifier, // index
            TokenType.parenthesisRight,
            TokenType.arrow,
            TokenType.newLine,
            TokenType.indent,
            TokenType.identifier, // ListTile
            TokenType.newLine,
            TokenType.indent,
            TokenType.identifier, // title
            TokenType.colon,
            TokenType.identifier, // Text
            TokenType.parenthesisLeft,
            TokenType.identifier, // todo
            TokenType.dot,
            TokenType.identifier, // title
            TokenType.parenthesisRight,
            TokenType.eof,
          ]));
    });
  });
}
