# DPug - Dart Pug-like Widget Builder

Inspired by [code_builder](https://github.com/dart-lang/tools/tree/main/pkgs/code_builder/lib), DPug provides a clean, indentation-based syntax for Flutter widgets.

## Key Features

- Pug-like indentation-based syntax
- Automatic handling of children/child properties
- Support for cascade notation (`..`) and positional arguments
- State management helpers
- Built using immutable collections

The goal is to provide chains:

- Dart String -> Dart Specs -> Dpug Specs -> DPug String
- Dpug String -> Dpug Specs -> Dart Specs -> Dart String

And in future the goods idea is to replace annotations with dart annotations, so the generation will be used only for Flutter widget tree, and other dart code will looks almost idential to the original one, since it's not dart replacement tool, but rather widget tree editor.

## Basic Example

```dartpug
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

Generates:

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

## Syntax Features

### Children Property Handling

Widgets that accept children automatically handle the children property:

```dartpug
Column
  TextFormField
    ..initialValue: newTodo
    ..onChanged: (value) => newTodo = value
```

Generates:

```dart
Column(
  children: [
    TextFormField(
      initialValue: newTodo,
      onChanged: (value) => newTodo = value,
    ),
  ],
)
```

### Single Child Property

Widgets with a single child property automatically handle it:

```dartpug
SizedBox
  TextFormField
    ..initialValue: newTodo
    ..onChanged: (value) => newTodo = value
```

Generates:

```dart
SizedBox(
  child: TextFormField(
    initialValue: newTodo,
    onChanged: (value) => newTodo = value,
  ),
)
```

### Positional Arguments

Two styles supported:

```dartpug
Column
  Text
    ..'Hello'  # Cascade style
  Text('World')  # Function call style
```

Generates:

```dart
Column(
  children: [
    Text('Hello'),
    Text('World'),
  ]
)
```

## Formatting Rules

### 1. Indentation Levels

- **Class Level (0)**: Classes and their annotations start at level 0

  ```dartpug
  @stateful
  class TodoList
  ```

- **Class Members (1)**: Fields, getters, and methods are indented one level

  ```dartpug
  class TodoList
    @listen String name = ''
    Widget get build =>
  ```

- **Widget Tree (Parent + 1)**: Each widget is indented one level from its parent
  ```dartpug
  Column
    Container
      Text
  ```

### 2. Properties and Arguments

- **Named Properties**: Use cascade notation, indented one level from widget

  ```dartpug
  Container
    ..width: 100
    ..height: 200
  ```

- **Positional Arguments**: Two styles supported

  ```dartpug
  // Cascade style - indented one level
  Text
    ..'Hello'

  // Function style - same level
  Text('World')
  ```

### 3. Special Cases

- **Build Method**: Special formatting for build method

  ```dartpug
  Widget get build =>
    Column
      Text('Hello')
  ```

- **Single Child Widgets**: Automatically handle child property

  ```dartpug
  Container
    ..color: Colors.red
    Center
      Text('Centered')
  ```

- **Multi-Child Widgets**: Automatically handle children list
  ```dartpug
  Column
    Text('First')
    Text('Second')
  ```

### 4. State Management

- **State Fields**: Annotations align with fields

  ```dartpug
  @listen String name = ''
  @listen int count = 0
  ```

- **Getters and Setters**: Generated with proper indentation
  ```dartpug
  String get name => _name
  set name(String value) => setState(() => _name = value)
  ```

### 5. Callbacks and Functions

- **Lambda Expressions**: Maintain readability with proper indentation

  ```dartpug
  ElevatedButton
    ..onPressed: () => setState(() => count++)
    ..child: Text('Increment')
  ```

  or

  ```dartpug
  ElevatedButton
    ..onPressed: () => setState(() => count++)
    Text('Increment')
  ```

- **Multi-line Callbacks**: Indent body one level
  ```dartpug
  ElevatedButton
    ..onPressed: () {
      setState(() {
        count++;
        name = 'Clicked';
      })
    }
  ```

### 6. Nested Structures

- **Nested Widgets**: Each level adds one indent

  ```dartpug
  Scaffold
    ..appBar: AppBar
      ..title: Text('Title')
    ..body: Container
      ..padding: EdgeInsets.all(16)
      Column
        Text('First')
        Text('Second')
  ```

- **Complex Properties**: Maintain alignment with parent
  ```dartpug
  Container
    ..decoration: BoxDecoration
      ..color: Colors.blue
      ..borderRadius: BorderRadius.circular(8)
    Text('Content')
  ```

## Architecture

### Core Components

1. **Builders**:

   - `DpugClassBuilder`: Builds stateful widget classes
   - `DpugWidgetBuilder`: Builds widget instances
   - `WidgetHelpers`: Provides syntax sugar for common widgets

2. **Specs**:

   - `DpugSpec`: Base specification
   - `DpugClassSpec`: Class specification
   - `DpugWidgetSpec`: Widget specification
   - `DpugMethodSpec`: Method specification
   - `DpugExpressionSpec`: Expression specifications

3. **Visitors**:
   - `DpugVisitor`: Generates DPug specs
   - `DartVisitor`: Generates Dart specs
   - `DpugEmitter`: Emits DPug code from specs to String
   - `DartToDpugVisitor`: Converts Dart specs to DPug specs

### Key Design Decisions

1. Uses `built_collection` for immutable data structures
2. Separates building, specification, and generation concerns
3. Provides both high-level builders and low-level specs
4. Uses visitor pattern for code generation
5. Supports multiple output formats (Dart/DPug)

## Usage Examples

### Creating a Stateful Widget

```dart
final widget = Dpug.classBuilder()
  ..name('MyWidget')
  ..annotation(DpugAnnotationSpec.stateful())
  ..listenField(
    name: 'count',
    type: 'int',
    initializer: DpugExpressionSpec.literal(0),
  )
  ..buildMethod(
    body: WidgetHelpers.column(
      children: [
        // Add children here
      ],
    ),
  );
```

### Using Widget Helpers

```dart
WidgetHelpers.column(
  properties: {
    'mainAxisAlignment': DpugExpressionSpec.reference('MainAxisAlignment.center'),
  },
  children: [
    // Add children here
  ],
)
```

## Implementation Notes

1. State Management:

   - `@listen` generates getters/setters with setState
   - State fields are automatically initialized from widget

2. Code Generation:

   - Uses code_builder for Dart output
   - Custom formatter for DPug output
   - Maintains proper indentation and formatting

3. Widget Building:

   - Automatic children/child property handling
   - Support for both cascade and function call styles
   - Property and positional argument support

4. Testing:
   - Tests both Dart and DPug output
   - Verifies formatting and indentation
   - Checks state management generation
