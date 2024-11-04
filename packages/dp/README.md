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

## Syntax Example

.dpug file

```Dart
@stateful
class TodoList {
  @listen List<Todo> todos = [];
  @listen String newTodo = '';
  @state String searchQuery = '';

  Widget get build =>
    Column
      TextField
        value: newTodo
        onChanged: (value) => newTodo = value
      ..padding(16)
      Button
        "Add Todo"
        action: () {
          todos.add(Todo(newTodo));
          newTodo = '';
        }
      ListView.builder
        itemCount: todos.length
        itemBuilder: (context, index) =>
          ListTile
            title: Text(todo.title)
            trailing: IconButton
              icon: Icon(Icons.delete)
              onPressed: () => todos.removeAt(index)
}
```

## Project Structurelib/

├── dpug/
│ ├── compiler/
│ │ ├── lexer.dart
│ │ ├── parser.dart
│ │ ├── ast_builder.dart
│ │ └── dart_generator.dart
│ └── analysis_server/
│ └── server_plugin.dart
└── builder.dart

## Core Components

1. **Lexer**: Tokenizes DPug syntax
2. **Parser**: Converts tokens to AST
3. **AST Builder**: Creates type-safe AST
4. **Dart Generator**: Generates Dart code
5. **Analyzer Plugin**: Provides IDE support

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
