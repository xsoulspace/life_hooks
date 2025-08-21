# DPug Complete Setup Guide

This guide walks you through setting up DPug from scratch, including the VS Code extension, formatter, and development tools.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Core Installation](#core-installation)
3. [VS Code Extension Setup](#vs-code-extension-setup)
4. [Using the Formatter](#using-the-formatter)
5. [HTTP API Setup](#http-api-setup)
6. [Development Workflow](#development-workflow)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements

- **Dart SDK**: 3.8.1 or later
- **Flutter**: 3.32 or later (for Flutter integration)
- **Node.js**: 18+ (for VS Code extension development)
- **VS Code**: 1.74.0 or later
- **Git**: For cloning repositories

### Installation

```bash
# Install Dart SDK
# Download from: https://dart.dev/get-dart

# Install Flutter
# Download from: https://flutter.dev/docs/get-started/install

# Verify installations
dart --version
flutter --version
```

## Core Installation

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/dpug.git
cd dpug
```

### 2. Install Dependencies

```bash
# Navigate to the core package
cd dp_packages/dpug_core

# Install dependencies
dart pub get

# Verify installation
dart analyze
```

### 3. Basic Usage Test

```bash
# Create a test file
echo 'Text
  ..text: "Hello DPug!"
  ..style:
    TextStyle
      ..fontSize: 16.0' > test.dpug

# Test the converter
dart run lib/compiler/dpug_converter.dart --help
```

## VS Code Extension Setup

### Option 1: Install from Source (Recommended for Development)

1. **Open VS Code Extension Directory**

```bash
cd dp_packages/vscode_extension
```

2. **Install Dependencies**

```bash
npm install
```

3. **Build Extension**

```bash
npm run compile
```

4. **Launch Extension Development Host**

- Press `F5` in VS Code
- This opens a new VS Code window with the extension loaded

### Option 2: Install from Marketplace (When Available)

1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search for "DPug Language Support"
4. Click Install

### Extension Configuration

1. **Open Settings** (Ctrl+,)
2. **Search for "dpug"**
3. **Configure Server Settings**:

```json
{
  "dpug.server.host": "localhost",
  "dpug.server.port": 8080
}
```

4. **Configure Formatting**:

```json
{
  "dpug.formatting.formatOnSave": true,
  "dpug.formatting.compact": false,
  "dpug.formatting.indent": "  "
}
```

## Using the Formatter

### CLI Usage

#### Format Single File

```bash
cd dp_packages/dpug_core

# Format a DPug file
dart run lib/compiler/dpug_formatter.dart lib/widgets.dpug
```

#### Format Multiple Files

```bash
# Format all .dpug files in a directory
dart run lib/compiler/dpug_formatter.dart lib/*.dpug

# Format recursively
find lib -name "*.dpug" -exec dart run lib/compiler/dpug_formatter.dart {} \;
```

#### Check Formatting (CI/CD)

```bash
# Check if files are formatted correctly (exit code 1 if not)
dart run lib/compiler/dpug_formatter.dart --check lib/

# In CI/CD pipeline
dart run lib/compiler/dpug_formatter.dart --check lib/ || exit 1
```

#### Formatting Options

```bash
# Use compact formatting
dart run lib/compiler/dpug_formatter.dart --compact lib/

# Use readable formatting (default)
dart run lib/compiler/dpug_formatter.dart --readable lib/

# Custom indentation
dart run lib/compiler/dpug_formatter.dart --indent="    " lib/
```

### VS Code Integration

#### Format on Save

1. **Enable in Settings**:

   - Open Settings (Ctrl+,)
   - Search "dpug"
   - Check "Dpug › Formatting: Format On Save"

2. **Manual Formatting**:
   - Open Command Palette (Ctrl+Shift+P)
   - Run "DPug: Format Document"
   - Or use keyboard shortcut (configure in settings)

## HTTP API Setup

### Start the Server

```bash
# From dpug_core directory
cd dp_packages/dpug_core

# Start server on default port (8080)
dart run ../dpug_server/bin/server.dart

# Start on custom port
dart run ../dpug_server/bin/server.dart --port 3000

# Enable verbose logging
dart run ../dpug_server/bin/server.dart --verbose
```

### API Endpoints

#### Health Check

```bash
curl http://localhost:8080/health
# Response: "ok"
```

#### Convert DPug to Dart

```bash
curl -X POST http://localhost:8080/dpug/to-dart \
  -H "Content-Type: text/plain" \
  -d '@stateful
class Counter
  @listen int count = 0

  Widget get build =>
    Text
      ..text: "Count: \$count"'
```

#### Convert Dart to DPug

```bash
curl -X POST http://localhost:8080/dart/to-dpug \
  -H "Content-Type: text/plain" \
  -d 'class Counter extends StatefulWidget {
  const Counter({super.key});
  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  @override
  Widget build(BuildContext context) {
    return Text("Hello");
  }
}'
```

#### Format DPug Code

```bash
curl -X POST http://localhost:8080/format/dpug \
  -H "Content-Type: text/plain" \
  -d 'Text
  ..text:"Hello World"'
```

## Development Workflow

### 1. Project Structure

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
│   └── test/           # Server tests
└── vscode_extension/   # VS Code extension
    ├── src/           # TypeScript source
    └── syntaxes/      # TextMate grammars
```

### 2. Running Tests

```bash
# Core functionality tests
cd dp_packages/dpug_core
dart test test/dpug_core_test.dart

# Formatter tests
dart test test/dpug_formatter_test.dart

# Parser tests
dart test test/dpug_parser_test.dart

# Server tests
cd ../dpug_server
dart test test/server_test.dart

# Code builder tests
cd ../dpug_code_builder
dart test test/dpug_code_builder_test.dart

# Run all tests
find . -name "*test*.dart" -exec dart test {} \;
```

### 3. Adding New Features

#### Adding a New Widget

1. **Update Parser**: Add widget to `dpug_grammar.dart`
2. **Update AST**: Add support in `ast_builder.dart`
3. **Update Code Gen**: Add generation in `ast_to_dart.dart`
4. **Add Tests**: Create tests for the new widget
5. **Update Docs**: Add to README and examples

#### Example: Adding Container Widget

```dpug
Container
  ..width: 100.0
  ..height: 100.0
  ..color: Colors.blue
  ..child:
    Text
      ..text: "Hello"
```

### 4. Debugging

#### Parser Issues

```bash
# Enable debug logging
cd dp_packages/dpug_core
dart run lib/compiler/dpug_converter.dart --debug your_file.dpug
```

#### Server Issues

```bash
# Check server logs
dart run ../dpug_server/bin/server.dart --verbose
```

#### Extension Issues

1. Open Command Palette (Ctrl+Shift+P)
2. Run "Developer: Toggle Developer Tools"
3. Check console for errors

## DPug Syntax Reference

### Basic Widget

```dpug
Text
  ..text: "Hello World"
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
      ..mainAxisAlignment: MainAxisAlignment.center
      Text
        ..text: "Count: \$count"
      ElevatedButton
        ..onPressed: () => count++
        ..child:
          Text
            ..text: "Increment"
```

### Widget with Children

```dpug
Column
  Text
    ..text: "Header"
  Row
    Text
      ..text: "Item 1"
    Text
      ..text: "Item 2"
```

### Properties and Events

```dpug
TextFormField
  ..initialValue: initialText
  ..onChanged: (value) => handleChange(value)
  ..decoration:
    InputDecoration
      ..labelText: "Enter text"
      ..hintText: "Type here"
```

## Troubleshooting

### Common Issues

#### "Parser error: letter expected"

- **Cause**: Invalid DPug syntax
- **Solution**: Check indentation and syntax
- **Example**: Ensure proper indentation and no syntax errors

#### "Server connection failed"

- **Cause**: DPug server not running
- **Solution**:
  ```bash
  cd dp_packages/dpug_core
  dart run ../dpug_server/bin/server.dart
  ```

#### "Extension not working"

- **Cause**: Extension not activated or server not configured
- **Solution**:
  1. Reload VS Code window (Ctrl+Shift+P → "Developer: Reload Window")
  2. Check extension settings
  3. Ensure server is running

#### "Formatting not applied"

- **Cause**: File not recognized as DPug or server error
- **Solution**:
  1. Ensure file has `.dpug` extension
  2. Check server logs for errors
  3. Verify formatting settings

### Getting Help

1. **Check Documentation**: See `docs/` directory for detailed guides
2. **Run Tests**: Ensure all tests pass with `dart test`
3. **Server Logs**: Check server output for detailed error messages
4. **VS Code Console**: Check developer console for extension errors

### Performance Tips

1. **Server Performance**: Keep server running for better performance
2. **Large Files**: Split large files for better formatting performance
3. **Batch Operations**: Use CLI for batch formatting instead of IDE for large projects

## Contributing

1. **Fork the repository**
2. **Create a feature branch**
3. **Add tests for new functionality**
4. **Ensure all tests pass**
5. **Submit a pull request**

## Roadmap

### Short Term (Next 1-2 months)

- ✅ Complete formatter implementation
- ✅ VS Code extension with basic features
- ✅ Comprehensive test suite
- 🔄 Enhanced error messages
- 🔄 More Flutter widget support

### Medium Term (3-6 months)

- 🔄 IntelliSense support
- 🔄 Refactoring tools
- 🔄 Performance optimizations
- 🔄 Plugin marketplace publication

### Long Term (6+ months)

- 🔄 Advanced language features
- 🔄 Integration with Flutter tooling
- 🔄 Community ecosystem growth

---

## Quick Start Summary

1. **Install**: `dart pub get` in dpug_core
2. **Start Server**: `dart run ../dpug_server/bin/server.dart`
3. **Install Extension**: From source or marketplace
4. **Format Code**: `dart run lib/compiler/dpug_formatter.dart file.dpug`
5. **Convert**: Use HTTP API or VS Code commands

That's it! You're ready to use DPug for concise Flutter development! 🚀
