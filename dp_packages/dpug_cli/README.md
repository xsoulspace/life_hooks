# DPug CLI

A unified command-line interface for DPug - the indentation-based syntax for Flutter/Dart widgets.

## Overview

DPug CLI provides a professional, consistent interface for all DPug operations including formatting, conversion, and server management. It's designed to follow established CLI patterns (similar to Flutter/Dart CLI tools) and provides a single entry point for all DPug functionality.

## Installation

### Global Installation

```bash
# Install from local path
cd dp_packages/dpug_cli
dart pub global activate --source path .

# Or install from pub.dev when published
dart pub global activate dpug_cli
```

### Local Installation

```bash
# For local development
cd dp_packages/dpug_cli
dart pub get

# Run directly
dart run bin/dpug.dart --help
```

## Usage

### Main Commands

```bash
dpug --help                    # Show all available commands
dpug format --help            # Show formatting options
dpug convert --help           # Show conversion options
dpug server --help            # Show server options
```

### Format Files

Format DPug files with consistent indentation and spacing.

```bash
# Format a single file (print to stdout)
dpug format my_widget.dpug

# Format multiple files
dpug format file1.dpug file2.dpug

# Format in-place (overwrite files)
dpug format -i *.dpug

# Format to specific output file
dpug format -o formatted.dpug input.dpug

# Format with verbose output
dpug format -v -i *.dpug

# Show help
dpug format --help
```

**Format Options:**

- `-i, --in-place`: Format files in place
- `-o, --output <file>`: Write output to specified file (single file only)
- `-v, --verbose`: Show detailed output

### Convert Files

Convert between DPug and Dart syntax.

```bash
# DPug to Dart conversion
dpug convert --from my_widget.dpug --to my_widget.dart

# Dart to DPug conversion
dpug convert --from my_widget.dart --to my_widget.dpug --format dart-to-dpug

# Convert with verbose output
dpug convert -v --from input.dpug --to output.dart

# Show help
dpug convert --help
```

**Convert Options:**

- `-f, --from <file>`: Input file to convert (required)
- `-t, --to <file>`: Output file (prints to stdout if not specified)
- `--format <format>`: Conversion format (dpug-to-dart or dart-to-dpug)
- `-v, --verbose`: Show detailed output

### Server Management

Start and manage the DPug HTTP server.

```bash
# Start the server
dpug server start --port=8080

# Start with custom host
dpug server start --host=0.0.0.0 --port=3000

# Check server health
dpug server health --port=8080

# Show help
dpug server --help
dpug server start --help
dpug server health --help
```

**Server Options:**

- `-p, --port <port>`: Port to bind to (default: 8080)
- `-h, --host <host>`: Host to bind to (default: localhost)

## Examples

### Basic Workflow

```bash
# 1. Create a DPug file
cat > counter.dpug << 'EOF'
@stateful
class Counter
  @listen int count = 0

  Widget get build =>
    Column
      Text
        ..text: 'Count: $count'
      ElevatedButton
        ..onPressed: () => count++
        ..child:
          Text
            ..text: 'Increment'
EOF

# 2. Format it
dpug format -i counter.dpug

# 3. Convert to Dart
dpug convert --from counter.dpug --to counter.dart

# 4. Start server for API access
dpug server start --port=8080
```

### CI/CD Integration

```bash
# Format check (exit with error if not formatted)
dpug format *.dpug | head -1 | grep -q "No changes needed" || exit 1

# Convert all DPug files to Dart
for file in *.dpug; do
  dpug convert --from "$file" --to "${file%.dpug}.dart"
done
```

### Development Workflow

```bash
# Format all files before commit
find lib -name "*.dpug" -exec dpug format -i {} \;

# Convert for debugging
dpug convert -v --from problematic.dpug --to debug.dart

# Quick server for testing
dpug server start --port=3000 &
SERVER_PID=$!

# Use API
curl -X POST http://localhost:3000/dpug/to-dart \
  -H "Content-Type: text/plain" \
  -d "Text ..'Hello'"

# Cleanup
kill $SERVER_PID
```

## Architecture

```
dpug_cli/
├── bin/dpug.dart              # Main CLI entry point
├── lib/
│   ├── dpug_cli.dart         # CLI utilities and base classes
│   └── commands/             # Command implementations
│       ├── format_command.dart
│       ├── convert_command.dart
│       └── server_command.dart
├── test/                      # Tests
└── README.md                  # This file
```

### Key Components

- **Command Runner**: Uses `package:args` for professional CLI experience
- **Modular Commands**: Each command is self-contained with its own help
- **Error Handling**: Consistent error messages and exit codes
- **Integration Ready**: Framework designed for easy integration with existing tools

## Exit Codes

- `0`: Success
- `1`: General error (invalid arguments, file not found, etc.)
- `2`: Conversion/parse errors
- `64`: Command usage error (wrong arguments)

## Error Messages

The CLI provides clear, actionable error messages:

```
Error: No input files specified
Usage: dpug format [arguments] <files...>

Error: File not found: missing.dpug
Please check the file path and try again.

Error: Conversion failed: Invalid DPug syntax at line 3
Use 'dpug format' to fix formatting issues.
```

## Development

### Adding New Commands

1. Create a new command class extending `Command`
2. Add it to the command runner in `bin/dpug.dart`
3. Follow the existing pattern for argument parsing and help text

### Testing

```bash
# Run all tests
dart test

# Run specific test
dart test test/format_command_test.dart

# Run with coverage
dart test --coverage=coverage
```

### Building

```bash
# Get dependencies
dart pub get

# Format code
dart format .

# Run linter
dart analyze

# Run tests
dart test
```

## Contributing

1. Follow the existing code style (use `dart format` and `dart analyze`)
2. Add tests for new functionality
3. Update documentation for any user-facing changes
4. Ensure all tests pass before submitting

## Related Packages

- **dpug_core**: Core compiler engine and parser
- **dpug_code_builder**: Code generation and formatting
- **dpug_server**: HTTP API server
- **vscode_extension**: VS Code extension with language server

## License

See the main DPug project license for details.
