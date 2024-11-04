# DartPug Project Context

## Overview

DartPug is a preprocessor and syntax extension for Flutter/Dart that enables SwiftUI-like declarative syntax with Pug-inspired indentation. It compiles to standard Dart code while maintaining full type safety and analyzer support.

## Key Features

- Indentation-based syntax
- Type-safe widget composition
- Smart state management (@listen, @state)
- Full Dart analyzer integration
- Source mapping for debugging
- Hot reload support
- IDE integration
- import from dart files and to dart files

## Syntax Example

### Idea 1

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

### Idea 2

.dpug file

```dartpug
import 'package:flutter/material.dart';

@stateful
class TodoList {
  @listen List<Todo> todos = [];
  @listen String newTodo = '';

  Widget get build =>
    Column
      TextField
        value: newTodo
        onChanged: (value) => newTodo = value
      Button
        "Add Todo"
        action: () {
          todos = [...todos, Todo(newTodo)];
          newTodo = '';
        }
      ListView.builder
        itemCount: todos.length
        itemBuilder: (context, index) =>
          ListTile
            title: Text(todo.title)
            trailing: IconButton
              icon: Icon(Icons.delete)
              onPressed: () => todos = [...todos]..removeAt(index)
}
```

## State Management

- `@listen` - Creates setState()-managed variables
- `@state` - Creates ValueNotifier-wrapped variables
- Auto-disposal of state objects

## Build System Integration

Uses Dart's build system with custom builder for .dpug files

## Current Implementation Status

- Basic syntax parsing (in progress)
- State management (in progress)
- Widget composition (in progress)
- Analyzer integration (in progress)
- Source mapping (in progress)
- IDE support (in progress)

## Next Steps

1. Improve error reporting
2. Add more widget builders
3. Enhance IDE support
4. Add testing infrastructure
5. Create documentation
