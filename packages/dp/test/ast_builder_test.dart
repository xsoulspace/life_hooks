import 'package:dpug_analyzer/compiler/ast_builder.dart';
import 'package:dpug_analyzer/compiler/lexer.dart';
import 'package:test/test.dart';

void main() {
  group('DPugASTBuilder', () {
    DPugNode buildAST(String input) {
      final lexer = DPugLexer(input);
      final tokens = lexer.tokenize();
      final builder = DPugASTBuilder(tokens);
      return builder.buildAST();
    }

    test('builds empty program', () {
      final ast = buildAST('');
      expect(ast.type, equals('Program'));
      expect(ast.nodeType, equals(NodeType.program));
      expect(ast.children, isEmpty);
    });

    test('builds stateful widget declaration', () {
      final input = '''
@stateful
class TodoList {
  @listen List<Todo> todos = [];
  @state String query = '';
}''';
      final ast = buildAST(input);

      expect(ast.children.length, equals(1));

      final classNode = ast.children.first;
      expect(classNode.nodeType, equals(NodeType.statefulWidget));
      expect(classNode.value, equals('TodoList'));

      final variables = classNode.children
          .where((node) =>
              node.nodeType == NodeType.listenVariable ||
              node.nodeType == NodeType.stateDeclaration)
          .toList();

      expect(variables.length, equals(2));
      expect(variables[0].properties['type'], equals('List<Todo>'));
      expect(variables[1].properties['type'], equals('String'));
    });

    test('builds widget tree', () {
      final input = '''
Column
  TextField
    value: newTodo
    onChanged: (value) => setState(() => newTodo = value)
  Button
    "Add Todo"
    action: () {
      todos.add(Todo(newTodo));
      newTodo = '';
    }
''';
      final ast = buildAST(input);

      final column = ast.children.first;
      expect(column.type, equals('Column'));
      expect(column.children.length, equals(2));

      final textField = column.children[0];
      expect(textField.type, equals('TextField'));
      expect(textField.properties.length, equals(2));

      final button = column.children[1];
      expect(button.type, equals('Button'));
      expect(button.children.length, equals(1));
    });

    test('builds arrow functions', () {
      final input = '(value) => newTodo = value';
      final ast = buildAST(input);

      final func = ast.children.first;
      expect(func.nodeType, equals(NodeType.arrowFunction));
      expect(func.children.length, equals(2)); // parameter and body

      final param = func.children[0];
      expect(param.value, equals('value'));

      final body = func.children[1];
      expect(body.nodeType, equals(NodeType.assignment));
    });

    test('builds block statements', () {
      final input = '''
{
  todos.add(Todo(newTodo));
  newTodo = '';
}''';
      final ast = buildAST(input);

      final block = ast.children.first;
      expect(block.nodeType, equals(NodeType.blockStatement));
      expect(block.children.length, equals(2));

      final methodCall = block.children[0];
      expect(methodCall.nodeType, equals(NodeType.methodCall));

      final assignment = block.children[1];
      expect(assignment.nodeType, equals(NodeType.assignment));
    });

    test('builds cascade operations', () {
      final input = 'TextField..padding(16)';
      final ast = buildAST(input);

      final cascade = ast.children.first;
      expect(cascade.nodeType, equals(NodeType.cascadeOperation));

      final method = cascade.children.first;
      expect(method.nodeType, equals(NodeType.methodCall));
      expect(method.value, equals('padding'));
    });
  });
}
