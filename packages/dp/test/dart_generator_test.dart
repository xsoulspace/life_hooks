import 'package:dpug_analyzer/compiler/ast_builder.dart';
import 'package:dpug_analyzer/compiler/dart_generator.dart';
import 'package:dpug_analyzer/compiler/lexer.dart';
import 'package:dpug_analyzer/compiler/source_mapper.dart';
import 'package:test/test.dart';

void main() {
  group('DartGenerator', () {
    String generateDart(String input) {
      final lexer = DPugLexer(input);
      final tokens = lexer.tokenize();
      final builder = DPugASTBuilder(tokens);
      final ast = builder.buildAST();
      final generator = DartGenerator(ast, SourceMapper());
      return generator.generate();
    }

    test('generates empty stateless widget', () {
      final input = '''
class EmptyWidget {
  Widget get build =>
    Container()
}''';
      final output = generateDart(input);

      expect(output, contains('class EmptyWidget extends StatelessWidget'));
      expect(output, contains('Widget build(BuildContext context)'));
      expect(output, contains('return Container('));
    });

    test('generates stateful widget with state variables', () {
      final input = '''
@stateful
class TodoList {
  @state String query = '';
  @listen List<Todo> todos = [];

  Widget get build =>
    Column
      TextField
        value: query
}''';
      final output = generateDart(input);

      expect(output, contains('class TodoList extends StatefulWidget'));
      expect(output, contains('class _TodoListState extends State<TodoList>'));
      expect(output, contains('String _query'));
      expect(output, contains('List<Todo> _todos'));
      expect(output, contains('Column('));
      expect(output, contains('TextField('));
      expect(output, contains('value: query'));
    });

    test('generates nested widgets with properties', () {
      final input = '''
class NestedWidget {
  Widget get build =>
    Column
      TextField
        value: text
        onChanged: (value) => setState(() => text = value)
      Button
        "Submit"
        onPressed: handleSubmit
}''';
      final output = generateDart(input);

      expect(output, contains('Column('));
      expect(output, contains('children: ['));
      expect(output, contains('TextField('));
      expect(output, contains('value: text'));
      expect(output, contains('onChanged:'));
      expect(output, contains('Button('));
      expect(output, contains('"Submit"'));
      expect(output, contains('onPressed: handleSubmit'));
    });

    test('generates cascade operations', () {
      final input = '''
class CascadeWidget {
  Widget get build =>
    Container
      child: Text("Hello")
      ..padding(EdgeInsets.all(16))
      ..margin(EdgeInsets.zero)
}''';
      final output = generateDart(input);

      expect(output, contains('Container('));
      expect(output, contains('child: Text("Hello")'));
      expect(output, contains('..padding(EdgeInsets.all(16))'));
      expect(output, contains('..margin(EdgeInsets.zero)'));
    });

    test('generates arrow functions', () {
      final input = '''
class CallbackWidget {
  Widget get build =>
    Button
      "Click me"
      onPressed: () => handleClick()
}''';
      final output = generateDart(input);

      expect(output, contains('Button('));
      expect(output, contains('"Click me"'));
      expect(output, contains('onPressed: () => handleClick()'));
    });

    test('generates block statements', () {
      final input = '''
class BlockWidget {
  Widget get build =>
    Button
      "Add"
      onPressed: () {
        items.add(newItem);
        newItem = '';
        setState(() {});
      }
}''';
      final output = generateDart(input);

      expect(output, contains('Button('));
      expect(output, contains('onPressed: () {'));
      expect(output, contains('items.add(newItem)'));
      expect(output, contains('newItem = '));
      expect(output, contains('setState(() {})'));
      expect(output, contains('}'));
    });
  });
}
