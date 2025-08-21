let's think.

I need to create:

1. dpug -> dart codegen
2. dart -> dpug codegen
   2.1 special syntax for flutter and different libraries for dpug
3. dpug format tool (cli)
4. vscode plugin to support formatting for dpug, and other features (goto code, see reference, see dart code, syntax highlight etc..)

the api:

```dpug
@stateful
class TodoList
  @listen List<Todo> todos = []
  @listen String newTodo = ''

  Widget get build =>
    Column
      ..mainAxisAlignment: MainAxisAlignment.center
      TextFormField
        ..initialValue: newTodo
        ..onChanged: (value) => newTodo = value
```

should be converted to

```dart
class TodoList extends StatefulWidget {
  TodoList({
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFormField(
          initialValue: newTodo,
          onChanged: (value) => newTodo = value,
        ),
      ],
    );
  }
}
```
