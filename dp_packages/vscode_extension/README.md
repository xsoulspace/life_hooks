# DPug VS Code Extension

A VS Code extension that provides comprehensive support for DPug - a concise, indentation-based syntax for Flutter widgets.

## Features

- **Syntax Highlighting**: Full DPug syntax highlighting with proper token recognition
- **Format on Save**: Automatically format DPug files when saving
- **Code Conversion**: Convert between DPug and Dart with commands
- **Language Server**: Integration with DPug HTTP server for advanced features

## Installation

### Option 1: From VS Code Marketplace (Recommended)

1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X / Cmd+Shift+X)
3. Search for "DPug Language Support"
4. Click Install

### Option 2: From Source

1. Clone the repository
2. Open the `vscode_extension` directory in VS Code
3. Run `bun install` to install dependencies
4. Press F5 to launch extension development host

## Configuration

### Server Configuration

The extension communicates with a DPug server. Configure it in your settings:

```json
{
  "dpug.server.host": "localhost",
  "dpug.server.port": 8080
}
```

### Formatting Configuration

```json
{
  "dpug.formatting.formatOnSave": true,
  "dpug.formatting.compact": false,
  "dpug.formatting.indent": "  "
}
```

## Usage

### Syntax Highlighting

DPug files (`.dpug`) will automatically have syntax highlighting applied. The extension recognizes:

- Annotations (`@stateful`, `@listen`)
- Keywords (`class`, `Widget`, `get`)
- Types (`int`, `String`, `bool`, etc.)
- Strings and numbers
- Properties and method calls

### Format on Save

By default, DPug files are automatically formatted when saved. You can disable this:

1. Open Settings (Ctrl+, / Cmd+,)
2. Search for "dpug"
3. Uncheck "Dpug › Formatting: Format On Save"

### Manual Formatting

Format the current DPug file:

1. Open a `.dpug` file
2. Open Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
3. Run "DPug: Format Document"

### Convert to Dart

Convert the current DPug file to Dart:

1. Open a `.dpug` file
2. Open Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
3. Run "DPug: Convert to Dart"

A new Dart file will be created with the converted code.

### Convert from Dart

Convert the current Dart file to DPug:

1. Open a `.dart` file
2. Open Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
3. Run "DPug: Convert from Dart"

A new DPug file will be created with the converted code.

## Server Setup

The extension requires a running DPug server. Start it with:

```bash
# From dpug_core package
dart run ../dpug_server/bin/server.dart

# Or specify custom port
dart run ../dpug_server/bin/server.dart --port 3000
```

## Examples

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

## Extension Development

### Prerequisites

- Node.js 18+
- bun
- TypeScript
- VS Code

### Building

```bash
cd vscode_extension
bun install
bun run compile
```

### Testing

```bash
bun run test
```

### Debugging

1. Open the extension in VS Code
2. Press F5 to launch debug session
3. This will open a new VS Code window with the extension loaded

## File Structure

```
vscode_extension/
├── package.json          # Extension manifest
├── src/
│   └── extension.ts      # Main extension code
├── syntaxes/
│   └── dpug.tmGrammar.json # TextMate grammar for syntax highlighting
└── README.md            # This file
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the extension
5. Submit a pull request

## Troubleshooting

### Server Connection Issues

If you see errors about connecting to the DPug server:

1. Ensure the DPug server is running
2. Check the server host/port configuration
3. Verify the server is accessible from VS Code

### Syntax Highlighting Not Working

1. Ensure the file has a `.dpug` extension
2. Reload VS Code window (Ctrl+Shift+P → "Developer: Reload Window")
3. Check that the extension is activated

### Formatting Not Working

1. Ensure the DPug server is running
2. Check the formatting configuration
3. Verify the current file is a `.dpug` file

## License

MIT License - see LICENSE file for details
