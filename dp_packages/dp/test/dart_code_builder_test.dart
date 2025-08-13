import 'package:code_builder/code_builder.dart';
import 'package:dpug/compiler/dart_code_builder.dart';
import 'package:test/test.dart';

void main() {
  group('DpugCodeBuilder', () {
    test('generates stateful widget with state management', () {
      final builder = DpugCodeBuilder();

      final code = builder.buildStatefulWidget(
        className: 'TodoList',
        stateFields: [
          StateField(
            name: 'todos',
            type: 'List<Todo>',
            annotation: '@listen',
          ),
        ],
        buildMethod: Code('''
          return Column(
            children: [
              TextField(
                value: newTodo,
                onChanged: (value) => newTodo = value,
              ),
            ],
          );
        '''),
      );

      expect(code, contains('class TodoList extends StatefulWidget'));
      expect(code, contains('class _TodoListState extends State<TodoList>'));
      expect(code, contains('List<Todo> get todos => _todos'));
      expect(code, contains('set todos(List<Todo> value)'));
    });
  });
}
