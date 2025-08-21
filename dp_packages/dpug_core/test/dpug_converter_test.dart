import 'package:dpug_core/compiler/dpug_converter.dart';
import 'package:test/test.dart';

const _dartCode = '''
class TodoList extends StatefulWidget {
  TodoList({
    required this.todos,
    required this.newTodo,
    super.key,
  });
  final List<Todo> todos;
  final String newTodo;
  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  late List<Todo> _todos = widget.todos;
  List<Todo> get todos => _todos;
  set todos(List<Todo> value) => setState(() => _todos = value);
  late String _newTodo = widget.newTodo;
  String get newTodo => _newTodo;
  set newTodo(String value) => setState(() => _newTodo = value);

  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          value: newTodo,
          onChanged: (value) => newTodo = value,
        ),
      ],
    );
  }
}''';
const _dpug = '''
@stateful
class TodoList
  @listen List<Todo> todos = []
  @listen String newTodo = ''

  Widget get build =>
    Column
      TextField
        value: newTodo
        onChanged: (value) => newTodo = value
''';

void main() {
  group('DartPug Converter', () {
    test('converts Dart to DartPug', () {
      final converter = DpugConverter();
      final dpugCode = converter.dartToDpug(_dartCode);

      expect(dpugCode, contains('@stateful\nclass TodoList'));
      expect(dpugCode, contains('Column\n  TextField'));
    });

    test('round-trip conversion preserves semantics', () {
      final converter = DpugConverter();
      final dart = converter.dpugToDart(_dpug);
      expect(dart, _dartCode);
      final backToDpug = converter.dartToDpug(dart);

      // Compare semantic structure, not exact formatting
      expect(backToDpug, _dpug);
    });
  });
}
