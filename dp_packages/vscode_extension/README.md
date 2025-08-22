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

The extension can automatically start and manage the DPug server. By default, the server starts automatically when you activate the extension.

### Automatic Server Management

The extension provides automatic server management:

- **Auto-start**: Server starts automatically when extension activates
- **Auto-stop**: Server stops automatically when extension deactivates
- **Health checks**: Extension monitors server health and restarts if needed
- **Manual control**: Use commands to manually start/stop/check server status

### Manual Server Control

You can also manually control the server using these commands:

1. Open Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
2. Run one of these commands:
   - **DPug: Start Server** - Start the DPug server manually
   - **DPug: Stop Server** - Stop the DPug server manually
   - **DPug: Server Status** - Check server status

### Configuration

Control automatic server behavior in your settings:

```json
{
  "dpug.server.autoStart": true,
  "dpug.server.autoStop": true,
  "dpug.server.host": "localhost",
  "dpug.server.port": 8080
}
```

### Manual Server Setup (Alternative)

If you prefer to run the server manually:

```bash
# From dpug_server package
dart run bin/server.dart --port 8080

# Or use dpug_cli
dpug server start --port 8080
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

The extension provides comprehensive debugging configurations for both the extension host and language server.

#### Quick Start

1. Open the extension in VS Code (`vscode_extension` folder)
2. Press F5 or go to Run & Debug panel (Ctrl+Shift+D)
3. Select "Run Extension" and click the play button
4. This opens a new VS Code window with the extension loaded

#### Available Debug Configurations

**Extension Debugging:**

- **Run Extension**: Standard extension debugging with compilation
- **Run Extension (Watch Mode)**: Extension debugging with automatic recompilation on file changes
- **Attach to Extension Host**: Attach to a running extension host on port 9229

**Language Server Debugging:**

- **Debug Language Server**: Attach to the language server process (port 6009)
- **Debug Extension and Server**: Combined debugging of both extension and language server

**Testing:**

- **Debug Extension Tests**: Run and debug extension tests

#### Combined Debugging

To debug both the extension and language server simultaneously:

1. Use "Debug Extension + Server" compound configuration
2. Or manually launch both:
   - Start "Run Extension"
   - Then start "Debug Language Server" in a second debug session

#### Debugging Features

**Extension Host:**

- Set breakpoints in `src/extension.ts`
- Debug command execution, document formatting, and conversions
- Inspect extension context and workspace state

**Language Server:**

- Set breakpoints in `src/server/dpug-language-server.ts`
- Debug LSP features: completion, hover, diagnostics, etc.
- Monitor language server communication via output channels

**Output Channels:**

- **DPug**: Extension logs and errors
- **DPug Language Server**: Language server logs and LSP communication

#### Debug Tips

1. **Source Maps**: The extension uses source maps for accurate debugging
2. **Hot Reload**: Use watch mode for automatic recompilation
3. **Language Server Port**: Server debugs on port 6009 by default
4. **Extension Host Port**: Can attach to port 9229 for extension host debugging
5. **Console Output**: Check VS Code's Debug Console for runtime logs

#### Troubleshooting

**Common Issues:**

- **Extension not activating**: Check that `.dpug` files are being recognized
- **Language server not starting**: Verify compilation completed successfully
- **Breakpoints not hit**: Ensure source maps are generated and paths are correct
- **Server connection fails**: Check if DPug HTTP server is running on the configured port

**Debug Checklist:**

1. ✅ Extension compiled successfully (check output panel)
2. ✅ Source maps generated (check `out/` directory)
3. ✅ DPug HTTP server running (default: localhost:8080)
4. ✅ Language server port not in use (6009)
5. ✅ Extension host port available if attaching (9229)

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
