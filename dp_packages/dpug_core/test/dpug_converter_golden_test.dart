import 'package:dpug_core/compiler/dpug_converter.dart';
import 'package:test/test.dart';

void main() {
  group('DPug Converter Golden Tests', () {
    test('converts Dart to DPug', () {
      final dartCode = '''
class TodoList extends StatefulWidget {
  const TodoList({
    super.key,
    required this.todos,
    required this.newTodo,
  });

  final List<Todo> todos;
  final String newTodo;

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  late List<Todo> _todos = widget.todos;
  late String _newTodo = widget.newTodo;

  List<Todo> get todos => _todos;

  set todos(List<Todo> value) => setState(() => _todos = value);

  String get newTodo => _newTodo;

  set newTodo(String value) => setState(() => _newTodo = value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: (value) => newTodo = value,
          decoration: const InputDecoration(
            labelText: 'New Todo',
          ),
        ),
      ],
    );
  }
}
''';

      final expectedDpug = '''
@stateful
class TodoList
  @listen List<Todo> todos = []
  @listen String newTodo = ''

  Widget get build =>
    Column
      TextField
        ..onChanged: (value) => newTodo = value
        ..decoration: const InputDecoration
          ..labelText: 'New Todo'
''';

      final converter = DpugConverter();
      final dpugCode = converter.dartToDpug(dartCode);

      expect(dpugCode, equals(expectedDpug));
    });
  });
}
