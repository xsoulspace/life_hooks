# DPUG CLI Example Project

This directory contains examples and demonstrations of the DPUG (Dart Pug) indentation-based syntax for Flutter widgets.

## 🎯 What is DPUG?

DPUG is a Pug-inspired, indentation-based syntax for Flutter/Dart that aims to provide a more concise and readable way to write Flutter widgets while maintaining full compatibility with existing Dart/Flutter ecosystem.

## 📋 Current Status

Based on our evaluation of the `DPUG_FEATURE_GAPS.md`:

### ✅ **Completed Features**

- **Unified CLI Architecture**: Professional CLI with commands for format, convert, and server ✅
- **Parser Validation & Error Handling**: Robust syntax validation and error reporting ✅
- **Core Conversion Engine**: DPUG ↔ Dart bidirectional conversion works ✅

### ⚠️ **In Progress**

- **Code Generation Formatting**: Basic conversion works, but some formatting issues remain ⚠️

### 🚧 **Pending Features** (from gaps analysis)

- Comments support
- Advanced control flow & expressions
- Function & method definitions
- Language server enhancements
- Advanced IntelliSense

## 🚀 Getting Started

### 1. Install DPUG CLI

```bash
# Install globally from local development version
cd /Users/antonio/xs/life_hooks/dp_packages/dpug_cli
dart pub global activate --source path .
```

### 2. Verify Installation

```bash
dpug --help
```

## 📖 Examples

### Counter Widget

**DPUG Syntax** (`counter_widget.dpug`):

```dpug
@stateful
class CounterWidget
  @listen int count = 0

  void increment() =>
    count++

  void decrement() =>
    count--

  void reset() =>
    count = 0

  Widget get build =>
    Container
      padding: EdgeInsets.all(16.0)
      child:
        Column
          mainAxisAlignment: MainAxisAlignment.center
          children:
            Text
              'Count: \$count'
              style:
                TextStyle
                  fontSize: 32.0
                  fontWeight: FontWeight.bold
                  color: Colors.blue
            SizedBox
              height: 20.0
            Row
              mainAxisAlignment: MainAxisAlignment.spaceEvenly
              children:
                ElevatedButton
                  onPressed: () => decrement()
                  child:
                    Text
                      '-'
                ElevatedButton
                  onPressed: () => reset()
                  style:
                    ElevatedButton.styleFrom
                      backgroundColor: Colors.orange
                  child:
                    Text
                      'Reset'
                ElevatedButton
                  onPressed: () => increment()
                  child:
                    Text
                      '+'
```

**Equivalent Dart Code** (`counter_widget.dart`):

```dart
class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int count = 0;

  void increment() {
    setState(() {
      count++;
    });
  }

  void decrement() {
    setState(() {
      count--;
    });
  }

  void reset() {
    setState(() {
      count = 0;
    });
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Count: $count',
          style: const TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(onPressed: decrement, child: const Text('-')),
            ElevatedButton(
              onPressed: reset,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Reset'),
            ),
            ElevatedButton(onPressed: increment, child: const Text('+')),
          ],
        ),
      ],
    ),
  );
}
```

### Todo List Widget

**DPUG Syntax** (`todo_list.dpug`):

```dpug
@stateful
class TodoList
  @listen List<String> todos = ['Learn DPUG', 'Build Flutter app', 'Test conversion']
  @listen String newTodo = ''

  void addTodo() =>
    if newTodo.isNotEmpty
      todos = [...todos, newTodo]
      newTodo = ''

  void removeTodo(int index) =>
    todos = todos.where((todo) => todo != todos[index]).toList()

  Widget get build =>
    Scaffold
      appBar:
        AppBar
          title: Text 'Todo List'
      body:
        Column
          children:
            Padding
              padding: EdgeInsets.all(16.0)
              child:
                Row
                  children:
                    Expanded
                      child:
                        TextField
                          controller: TextEditingController text: newTodo
                          onChanged: (value) => newTodo = value
                          decoration:
                            InputDecoration
                              hintText: 'Enter new todo...'
                              border: OutlineInputBorder()
                    SizedBox
                      width: 10.0
                    ElevatedButton
                      onPressed: () => addTodo()
                      child: Text 'Add'
            Expanded
              child:
                if todos.isEmpty
                  Center
                    child:
                      Text
                        'No todos yet!'
                        style:
                          TextStyle
                            fontSize: 18.0
                            color: Colors.grey
                else
                  ListView.builder
                    itemCount: todos.length
                    itemBuilder: (context, index) =>
                      Card
                        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0)
                        child:
                          ListTile
                            title: Text todos[index]
                            trailing:
                              IconButton
                                icon: Icon Icons.delete
                                onPressed: () => removeTodo(index)
```

## 🛠 CLI Commands

### Convert DPUG to Dart

```bash
dpug convert --from counter_widget.dpug --to counter_widget.dart --format dpug-to-dart
```

### Convert Dart to DPUG

```bash
dpug convert --from counter_widget.dart --to counter_widget.dpug --format dart-to-dpug
```

### Format DPUG Files

```bash
dpug format counter_widget.dpug
dpug format todo_list.dpug --in-place
```

### Start HTTP Server

```bash
dpug server start --port=8080
dpug server health
```

### Show Help

```bash
dpug --help
dpug convert --help
dpug format --help
dpug server --help
```

## 🎮 Run the Demo

Execute the interactive demo script:

```bash
dart demo.dart
```

Or use the bash version:

```bash
chmod +x demo.sh
./demo.sh
```

## 📊 Demo Results

The demo script successfully demonstrates:

✅ **DPUG → Dart Conversion**: Working perfectly
✅ **Dart → DPUG Conversion**: Working perfectly
⚠️ **DPUG Formatting**: Has some issues (formatting gaps)
⚠️ **Round-trip Conversion**: Has some issues (formatting gaps)

## 🔧 Architecture

The DPUG CLI is built with a clean, modular architecture:

```
dpug_cli/
├── bin/dpug.dart              # Main CLI entry point
├── lib/
│   ├── commands/              # Command implementations
│   │   ├── convert_command.dart
│   │   ├── format_command.dart
│   │   └── server_command.dart
│   ├── dpug_cli.dart         # CLI utilities
│   └── dpug_cli.dart         # Main CLI framework
└── example/                  # Example files and demos
```

## 🔗 Integration

The DPUG CLI integrates with:

- **dpug_core**: Core compiler engine (lexer, parser, AST, converters)
- **dpug_code_builder**: Code generation utilities and IR/specs
- **dpug_server**: HTTP API server for conversion/formatting

## 🎯 Key Benefits

1. **Unified Tool**: One command for all DPUG operations
2. **Professional UX**: Follows established CLI patterns
3. **Easy Discovery**: Built-in help and command completion
4. **Consistent Interface**: Unified error handling and output formatting
5. **Developer Friendly**: Single installation, everywhere usage

## 📈 Future Roadmap

Based on the feature gaps analysis, planned improvements include:

1. **Comments Support**: Add `# comments` parsing
2. **Enhanced Formatting**: Fix indentation and newline handling
3. **Control Flow**: Add `if`/`else`, `for`/`while` syntax
4. **Advanced Expressions**: Map literals, spread operators
5. **Method Definitions**: Custom method syntax
6. **Language Server**: Enhanced IDE support

## 🐛 Known Issues

1. **Comments**: `# comments` are not yet supported
2. **Formatting**: Some formatting inconsistencies remain
3. **Round-trip**: Not all files convert perfectly back and forth
4. **Advanced Syntax**: Complex expressions may need refinement

## 🤝 Contributing

To contribute to DPUG development:

1. Check the `DPUG_FEATURE_GAPS.md` for current priorities
2. Test with the example files in this directory
3. Run the demo script to verify functionality
4. Submit issues or pull requests to the main repository

## 📚 Resources

- [DPUG Project Overview](../../DPUG_PROJECT_OVERVIEW_SCRATCH.md)
- [DPUG Feature Gaps Analysis](../../DPUG_FEATURE_GAPS.md)
- [DPUG Setup Guide](../../DPUG_SETUP_GUIDE.md)

---

**DPUG CLI Demo - Successfully Tested!** 🎉

This example project demonstrates that the core DPUG functionality is working well. The CLI provides a solid foundation for DPUG development, with room for the remaining features to be implemented as prioritized in the gaps analysis.
