# DPug - Dart Pug-like Widget Builder

Inspired by [code_builder](https://github.com/dart-lang/tools/tree/main/pkgs/code_builder/lib), DPug provides a clean, indentation-based syntax for Flutter widgets.

## Key Features

- Pug-like indentation-based syntax
- Automatic handling of children/child properties
- Support for cascade notation (`..`) and positional arguments
- State management helpers
- Built using immutable collections

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

### 7. Configuration

Indentation is configurable through `DpugConfig`:

```dart
final formatter = DpugFormatter(
  DpugConfig(indent: '  '), // Two spaces
  // or
  DpugConfig(indent: '\t'), // Tab
);
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
   - `DartGeneratingVisitor`: Generates Dart code
   - `DpugGeneratingVisitor`: Generates DPug code
   - `DpugFormatter`: Handles indentation and formatting

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

## Writing Tests

This test suite is designed to verify and maintain the core functionality
of the DPug (Dart Pug-like) syntax generator. Here's how to work with these tests:

1.  Test Structure
    Each test group focuses on a specific aspect of DPug:

- Basic widget functionality
- Critical edge cases
- State management
- Complex callbacks
- Multiple classes

2.  Test Pattern
    Each test follows this pattern:
    a) Build a widget/class using DPug builders
    b) Generate both Dart and DPug code
    c) Compare with expected output
    d) Verify formatting rules

3.  Adding New Tests
    When adding new tests, consider:

- Edge cases in Flutter widgets
- Complex state management scenarios
- Nested widget structures
- Callback patterns
- Formatting edge cases

4.  Modifying Tests
    When modifying existing tests:

- Maintain both Dart and DPug expected outputs
- Follow formatting rules from README.md
- Consider impact on existing test cases
- Verify against Flutter widget patterns

5.  Test Categories
    a) Widget Tests:
    - Single child widgets
    - Multi-child widgets
    - Mixed argument styles
    - Nested properties

b) State Management Tests: - Field initialization - Getter/setter generation - State updates in callbacks

c) Callback Tests: - Simple lambda expressions - Multi-line callbacks - Async operations - Error handling

d) Multiple Class Tests: - Class separation - State isolation - Widget interaction

6.  Common Patterns

- Use `Dpug.classBuilder()` for widget classes
- Use `WidgetHelpers` for common widgets
- Use `DpugExpressionSpec` for values
- Compare both Dart and DPug output

7.  Debugging Tests
    When tests fail, check:

- Indentation levels
- Property ordering
- Callback formatting
- State field generation
- Widget tree structure

8.  Example Test Structure:

```dart
test('descriptive name', () {
  // 1. Setup
  final widget = (Dpug.classBuilder()
    ..name('WidgetName')
    // ... configuration ...
  ).build();

  // 2. Generate code
  final dartCode = widget.accept(DartGeneratingVisitor());
  final dpugCode = widget.accept(DpugGeneratingVisitor());

  // 3. Define expectations
  final expectedDartCode = '''...''';
  final expectedDpugCode = '''...''';

  // 4. Assert
  expect(dartCode, equals(expectedDartCode));
  expect(dpugCode, equals(expectedDpugCode));
});
```

9.  Key Considerations

- Maintain consistent formatting
- Test both simple and complex cases
- Verify state management
- Check widget tree structure
- Validate callback handling
- Ensure proper indentation
- Test error cases

10. Future Additions
    Consider adding tests for:

- More widget patterns
- Complex state management
- Advanced callbacks
- Error handling
- Edge cases
- Performance scenarios

Remember: These tests serve as both verification and documentation
of the DPug syntax and behavior.
