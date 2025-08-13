import 'package:dpug_core/dpug_core.dart';
import 'package:test/test.dart';

void main() {
  group('DartPug AST Builder', () {
    test('builds AST for simple widget tree', () {
      final input = '''
Column
  TextField
    value: newTodo
''';
      final lexer = Lexer(input);
      final tokens = lexer.tokenize();
      final astBuilder = ASTBuilder(tokens);
      final ast = astBuilder.build();

      expect(
        ast,
        isA<WidgetNode>()
            .having((w) => w.name, 'name', 'Column')
            .having((w) => w.children.length, 'children count', 1),
      );
    });

    test('handles state declarations', () {
      final input = '''
@stateful
class TodoList
  @listen List<Todo> todos = []''';
      final lexer = Lexer(input);
      final tokens = lexer.tokenize();
      final astBuilder = ASTBuilder(tokens);
      final ast = astBuilder.build();

      expect(
        ast,
        isA<ClassNode>()
            .having((c) => c.name, 'name', 'TodoList')
            .having((c) => c.annotations.length, 'annotations count', 1),
      );
    });
  });
}
