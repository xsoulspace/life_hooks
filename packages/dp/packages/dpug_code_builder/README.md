inspired by [code_builder](https://github.com/dart-lang/tools/tree/main/pkgs/code_builder/lib) system to build classes for dpug easily

```dartpug
@stateful
class TodoList
  @listen List<Todo> todos = []
  @listen String newTodo = ''

  Widget get build =>
    Column
      TextField
        value: newTodo
        onChanged: (value) => newTodo = value
```

equivalent dart code:

```dart
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
}
```
