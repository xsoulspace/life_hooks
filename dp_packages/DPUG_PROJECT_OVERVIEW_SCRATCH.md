# DPUG Project Overview

## Project Mission

DPug is a Pug-inspired, indentation-based syntax for Flutter/Dart with bidirectional conversion (DPug ↔ Dart). It aims to provide a more concise and readable way to write Flutter widgets while maintaining full compatibility with existing Dart/Flutter ecosystem.

## Architecture Overview

### Package Structure

- **dpug_core**: Core compiler engine (lexer, parser, AST, converters)
- **dpug_code_builder**: Code generation utilities and IR/specs
- **dpug_server**: HTTP API server for conversion/formatting
- **dpug_cli**: 🏆 Unified CLI package (HIGHEST PRIORITY - NEW)
- **vscode_extension**: VS Code extension with language server support

### Key Components

#### 1. dpug_core (Compiler Engine)

**Status: ✅ CORE ISSUES FIXED** - Parser validation and error handling working correctly

```
lib/compiler/
├── lexer.dart          # Tokenizes DPug source
├── dpug_grammar.dart   # PetitParser grammar definitions
├── dpug_parser.dart    # Parser with validation ✅ ENHANCED
├── ast_builder.dart    # AST construction from tokens ✅ VALIDATION ADDED
├── ast_to_dart.dart    # DPug AST → Dart code generation
├── dart_to_dpug.dart   # Dart AST → DPug code generation
├── dpug_converter.dart # Main conversion API
└── dpug_formatter.dart # Code formatting
```

**✅ Recent Fixes:**

- Added `_validateAnnotation()` method - rejects invalid annotations
- Added `_validateWidgetName()` method - validates widget identifiers
- Enhanced `isValid()` method to use full AST validation
- Function-style positional arguments (`Text('Hello')`) now working
- Proper error messages with source location information

#### 2. dpug_code_builder (Code Generation)

**Status: ⚠️ Working but with formatting issues**

```
lib/src/
├── builders/          # Code generation builders
├── specs/            # IR specifications (23 files)
├── visitors/         # AST visitors
└── formatters/       # Formatting configurations
```

#### 3. dpug_server (HTTP API)

**Status: ✅ Fully Working**

```
lib/server.dart        # Shelf-based HTTP server
bin/server.dart        # CLI server runner
```

**API Endpoints:**

- `POST /dpug/to-dart` - DPug → Dart conversion
- `POST /dart/to-dpug` - Dart → DPug conversion
- `POST /format/dpug` - DPug formatting
- `GET /health` - Health check

#### 4. dpug_cli (Unified CLI) 🏆 HIGHEST PRIORITY - NEW

**Status: ✅ COMPLETED - Professional CLI with unified user experience**

**Mission:** Single entry point for all DPUG operations with professional UX

**User Experience:**

```bash
# Install once
dart pub global activate dpug

# Use everywhere
dpug format file.dpug
dpug convert --from=input.dpug --to=output.dart
dpug server start --port=8080
dpug server health
```

**Benefits:**

- **Single Tool Philosophy**: One command for all DPUG operations
- **Professional UX**: Follows established CLI patterns (like Flutter/Dart)
- **Easy Discovery**: Built-in help and command completion
- **Consistent Interface**: Unified error handling and output formatting

**Architecture:**

```
dpug_cli/
├── bin/dpug.dart          # Main CLI entry point
├── lib/commands/          # Command implementations
│   ├── format.dart       # Format command
│   ├── convert.dart      # Convert command
│   └── server.dart       # Server management
└── lib/dpug_cli.dart     # CLI framework
```

#### 5. vscode_extension (IDE Support)

**Status: ✅ Functional but needs testing**

```
src/
├── extension.ts       # Main extension logic
├── language-server.ts # Language server integration
└── server/
    └── dpug-language-server.ts # LSP implementation
syntaxes/dpug.tmGrammar.json    # Syntax highlighting
```

## Current Implementation Status

### ✅ Working Features

1. **Core Conversion**: DPug ↔ Dart round-trip conversion works
2. **HTTP Server**: All endpoints functional with proper error handling
3. **VS Code Extension**: Basic functionality with conversion commands
4. **Language Server**: Provides completion, hover, signatures
5. **Syntax Highlighting**: TextMate grammar for .dpug files

### ⚠️ Issues & Bugs

#### Critical Test Failures

1. **Parser Validation**: `dpug_core` parser accepts invalid syntax
2. **Error Handling**: Expected exceptions not thrown for invalid DPug
3. **Code Formatting**: Inconsistent indentation and spacing in generated code

#### Specific Test Failures

```
dpug_core/test/dpug_core_test.dart
❌ Error handling for invalid DPug (should throw exception)
❌ Syntax validation (parser too permissive)

dpug_core/test/dpug_converter_test.dart
❌ Dart to DPug conversion format mismatch
❌ Round-trip conversion formatting differences

dpug_code_builder/test/
❌ Multiple formatting and indentation issues
❌ AST visitor round-trip consistency problems
```

### 🔧 Missing/Incomplete Features

1. **Advanced Language Features**

   - Comments support (parser has # but not fully implemented)
   - Multi-line strings
   - Raw strings
   - Maps and collections syntax
   - Control flow (if/else, loops)

2. **Tooling**

   - CLI formatter tool (mentioned but not implemented)
   - CI/CD integration
   - Golden tests for regression testing

3. **IDE Features**
   - Go to definition (stub implementation)
   - Find references (stub implementation)
   - Advanced IntelliSense
   - Refactoring tools

## Priority Fixes

### HIGHEST Priority 🏆

1. **Create `dpug_cli` unified package** - This will dramatically improve user experience by providing a single entry point for all DPUG operations
2. Fix parser validation and error handling (critical test failures)
3. Fix code generation formatting issues (inconsistent indentation/spacing)

### High Priority

4. **Fix Round-trip Consistency** - DPug → Dart → DPug should preserve semantics
5. Implement comments support in parser
6. Add basic control flow syntax (if/else)
7. Enhance language server features (go-to-definition)

### Medium Priority

1. **Implement Comments** - Full comment support in parser
2. **Add Missing Syntax** - Maps, collections, control flow
3. **Improve Error Messages** - Better diagnostics with line/column info
4. **Add CLI Tools** - Format and convert from command line

### Low Priority

1. **Enhanced IDE Features** - Go to definition, find references
2. **Advanced Refactoring** - Extract widget, rename
3. **Performance Optimization** - Caching, incremental parsing

## Future Roadmap

### Phase 1: Stability (Current Focus)

- ✅ Fix all test failures
- ✅ Stabilize core conversion
- ✅ Complete basic language features

### Phase 2: Enhancement

- 🔄 Advanced language features (comments, multiline strings)
- 🔄 Enhanced IDE support
- 🔄 CLI tooling

### Phase 3: Ecosystem

- 🔄 Plugin marketplace publication
- 🔄 Community tooling and libraries
- 🔄 Performance optimizations
