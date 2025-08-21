# DPug Core

A concise, indentation-based syntax for Flutter widgets with bidirectional conversion to/from Dart.

## Features

- **Concise Syntax**: Write Flutter widgets with less boilerplate
- **Bidirectional Conversion**: Convert between DPug and Dart seamlessly
- **PetitParser Integration**: Modern, maintainable parser architecture
- **VS Code Support**: Full language extension with syntax highlighting
- **Formatter**: CLI tool for consistent code formatting
- **HTTP API**: REST endpoints for integrations

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  dpug_core: ^0.1.0
```

## Basic Usage

### 1. Convert DPug to Dart

```dart
import 'package:dpug_core/dpug_core.dart';

void main() {
  final converter = DpugConverter();

  const dpugCode = '''
@stateful
class Counter
  @listen int count = 0

  Widget get build =>
    Column
      Text
        ..text: 'Count: \$count'
      ElevatedButton
        ..onPressed: () => count++
        ..child:
          Text
            ..text: 'Increment'
''';

  final dartCode = converter.dpugToDart(dpugCode);
  print(dartCode);
}
```

### 2. Convert Dart to DPug

```dart
const dartCode = '''
class Counter extends StatefulWidget {
  const Counter({required this.count, super.key});
  final int count;

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  late int _count = widget.count;
  int get count => _count;
  set count(int value) => setState(() => _count = value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: \$count'),
        ElevatedButton(
          onPressed: () => count++,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
''';

final dpugCode = converter.dartToDpug(dartCode);
print(dpugCode);
```

## DPug Syntax

### Basic Widget

```dpug
Text
  ..text: 'Hello World'
  ..style:
    TextStyle
      ..fontSize: 16.0
      ..color: Colors.blue
```

### Stateful Widget

```dpug
@stateful
class Counter
  @listen int count = 0

  Widget get build =>
    Column
      Text
        ..text: 'Count: \$count'
      ElevatedButton
        ..onPressed: () => count++
        ..child:
          Text
            ..text: 'Increment'
```

### Widget with Children

```dpug
Column
  ..mainAxisAlignment: MainAxisAlignment.center
  Text
    ..text: 'Header'
  Row
    Text
      ..text: 'Item 1'
    Text
      ..text: 'Item 2'
```

## CLI Tools

### Formatter

Format DPug files:

```bash
# Format a single file
dart run dpug_formatter.dart lib/widgets.dpug

# Format multiple files
dart run dpug_formatter.dart lib/*.dpug

# Check if files are formatted (exit code 1 if not)
dart run dpug_formatter.dart --check lib/

# Use compact formatting
dart run dpug_formatter.dart --compact lib/
```

### Server

Start the HTTP API server:

```bash
# Start server on port 8080
dart run dpug_server/bin/server.dart

# Start on custom port
dart run dpug_server/bin/server.dart --port 3000
```

## VS Code Extension

### Installation

1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search for "DPug"
4. Install the extension

### Features

- **Syntax Highlighting**: Full DPug syntax highlighting
- **Format on Save**: Automatically format DPug files
- **Convert to Dart**: Convert DPug to Dart via command palette
- **Convert from Dart**: Convert Dart to DPug via command palette

### Commands

- `DPug: Format Document` - Format current DPug file
- `DPug: Convert to Dart` - Convert current DPug file to Dart
- `DPug: Convert from Dart` - Convert current Dart file to DPug

## HTTP API

### Endpoints

- `GET /health` - Health check
- `POST /dpug/to-dart` - Convert DPug to Dart
- `POST /dart/to-dpug` - Convert Dart to DPug
- `POST /format/dpug` - Format DPug code

### Usage

```bash
# Convert DPug to Dart
curl -X POST http://localhost:8080/dpug/to-dart \
  -H "Content-Type: text/plain" \
  -d "@stateful class Test
  @listen String name = 'Hello'"

# Convert Dart to DPug
curl -X POST http://localhost:8080/dart/to-dpug \
  -H "Content-Type: text/plain" \
  -d "class Test extends StatefulWidget { ... }"
```

## Development

### Running Tests

```bash
# Test core functionality
dart test test/dpug_core_test.dart

# Test formatter
dart test test/dpug_formatter_test.dart

# Test parser
dart test test/dpug_parser_test.dart

# Test server
dart test ../dpug_server/test/server_test.dart

# Test code builder
dart test ../dpug_code_builder/test/dpug_code_builder_test.dart
```

### Project Structure

```
dp_packages/
├── dpug_core/           # Core conversion engine
│   ├── lib/compiler/    # Parser, AST, converters
│   ├── test/           # Unit tests
│   └── docs/           # Documentation
├── dpug_code_builder/   # Code generation utilities
│   ├── lib/src/        # Builders and specifications
│   └── test/           # Tests
├── dpug_server/        # HTTP API server
│   ├── lib/           # Server implementation
│   └── test/          # Server tests
└── vscode_extension/   # VS Code extension
    ├── src/           # TypeScript source
    └── syntaxes/      # TextMate grammars
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License - see LICENSE file for details
