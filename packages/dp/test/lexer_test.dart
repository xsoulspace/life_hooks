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
            TokenType.identifier,
            TokenType.identifier,
            TokenType.equals,
            TokenType.braceLeft,
            TokenType.braceRight,
            TokenType.newLine,
            TokenType.state,
            TokenType.identifier,
            TokenType.identifier,
            TokenType.equals,
            TokenType.string,
            TokenType.newLine,
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
  });
}
