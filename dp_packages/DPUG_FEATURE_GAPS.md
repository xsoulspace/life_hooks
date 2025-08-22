# DPUG Feature Gaps Analysis

## Critical Missing Features

### 1. Parser Validation & Error Handling ✅ COMPLETED

**Current State:** Parser now properly validates DPug syntax and throws appropriate exceptions

**✅ Fixed Issues:**

- ✅ `dpug_parser_test.dart` syntax validation now passes
- ✅ `dpug_core_test.dart` error handling test now passes
- ✅ Parser rejects invalid annotations (`@invalid`, `@broken`)
- ✅ Parser validates widget names (must be valid Dart identifiers)
- ✅ Parser validates state field annotations (only `@listen` allowed)
- ✅ Function-style positional arguments (`Text('Hello')`) now working

**Implementation Details:**

- Added `_validateAnnotation()` method in `ASTBuilder`
- Added `_validateWidgetName()` method for identifier validation
- Enhanced `isValid()` method to use full AST validation instead of just grammar parsing
- Proper error messages with source location information

**Test Results:**

- Error handling test: ✅ PASSES
- Syntax validation test: ✅ PASSES
- Function-style arguments: ✅ PASSES

### 2. Code Generation Formatting ⚠️ IN PROGRESS

**Current State:** Code generation works but has formatting inconsistencies

**Remaining Issues:**

1. **Extra Blank Lines Between Fields**

   - Expected: Single blank line between class fields
   - Actual: Double blank lines in some cases

2. **Widget Indentation Issues**

   - Expected: Proper 2-space indentation for nested widgets
   - Actual: Inconsistent indentation in function-style syntax

3. **Multi-line Callback Indentation**

   - Expected: 2-space indentation for callback content
   - Actual: 4-space or inconsistent indentation

4. **Dart → DPug Conversion Formatting**

   - Expected: DPug-style indentation with cascade syntax
   - Actual: Function-style Dart syntax being preserved

5. **Trailing Newlines**
   - Expected: Consistent newline handling at end of files
   - Actual: Missing or extra newlines in some cases

**Test Failures:**

- **dpug_test.dart**: 6 formatting-related test failures
- **visitor_test.dart**: 4 round-trip conversion formatting failures

**Examples of Issues:**

```dart
// Issue 1: Extra blank lines
// Expected:
final int count;
final String name;

// Actual:
final int count;

final String name;

// Issue 2: Widget indentation
// Expected:
Widget get build =>
  Column
    Text
      ..'Hello'

// Actual:
Widget get build =>
Column(
                children: [
                  Text('Hello'),
                ],
              )

// Issue 3: Callback indentation
// Expected:
..onPressed: () {
  if (isEnabled) {
    setState(() {
      count++;
    });
  }
}

// Actual:
..onPressed: () {
      if (isEnabled) {
        setState(() {
          count++;
        });
      }
    }
```

**Required Fixes:**

1. **AST Visitors**: Update indentation logic in `dpug_to_dart_visitor.dart` and `dart_to_dpug_visitor.dart`
2. **Widget Formatting**: Ensure consistent cascade vs function-style syntax
3. **Newline Handling**: Standardize blank line insertion between class members
4. **Callback Formatting**: Fix multi-line callback indentation
5. **Round-trip Consistency**: Ensure DPug → Dart → DPug preserves formatting

### 3. Unified CLI Architecture ✅ COMPLETED

**Current State:** Professional CLI with commands for format, convert, and server

**✅ Completed Features:**

- ✅ **dpug_cli package**: Created unified CLI architecture
- ✅ **Format command**: `dpug format [options] <files...>`
- ✅ **Convert command**: `dpug convert --from input --to output`
- ✅ **Server command**: `dpug server start/health`
- ✅ **Professional UX**: Built-in help, error handling, consistent interface
- ✅ **Ready for integration**: Framework in place for existing tools

**Architecture:**

```
dpug_cli/
├── bin/dpug.dart          # Main CLI entry point
├── lib/commands/          # Command implementations
│   ├── format_command.dart
│   ├── convert_command.dart
│   └── server_command.dart
└── lib/dpug_cli.dart     # CLI framework
```

**User Experience:**

```bash
# Format files
dpug format my_widget.dpug
dpug format -i *.dpug

# Convert between formats
dpug convert --from input.dpug --to output.dart

# Start server
dpug server start --port=8080
dpug server health
```

### 4. Existing CLI Tool Integration 🚧 PENDING

**Current State:** Existing CLI tools need integration into unified architecture

**Required Integration:**

1. **Format Tool Integration**

   - `dpug_core/bin/dpug_format.dart` → `dpug format` command
   - `dpug_server/bin/format.dart` → `dpug format` command

2. **Server Integration**

   - `dpug_server/bin/server.dart` → `dpug server start` command

3. **Converter Integration**
   - `dpug_core` converter → `dpug convert` command

**Implementation Plan:**

- Update commands to use existing tool executables
- Maintain backward compatibility
- Add proper error handling and output formatting
- Ensure consistent CLI experience

### 5. Comments Support

**Current State:** Partial implementation in TextMate grammar but not in parser

**Missing:**

- Parser doesn't handle `# comments`
- No comment preservation in conversion
- No support for multi-line comments

**Required:**

```dpug
# This is a comment
@stateful
class Counter
  # State field comment
  @listen int count = 0

  Widget get build =>
    Text
      # Widget comment
      ..text: "Count: $count"
```

## Language Feature Gaps

### 4. Control Flow & Expressions

**Missing Syntax:**

- Conditional expressions (`if`/`else`)
- Loops (`for`/`while`)
- Switch statements
- Ternary operators

**Potential Syntax:**

```dpug
Widget get build =>
  Column
    if showHeader
      Text
        ..text: "Header"
    Text
      ..text: "Content"
```

### 5. Advanced Data Structures

**Missing:**

- Map literals syntax
- Set literals syntax
- Complex collection operations
- Spread operators (`...`)

**Potential Syntax:**

```dpug
@stateful
class DataList
  @listen List<Map<String, dynamic>> items = [
    {"name": "Item 1", "value": 100},
    {"name": "Item 2", "value": 200}
  ]
```

### 6. Function & Method Definitions

**Missing:**

- Custom method definitions
- Function declarations
- Closure syntax improvements

**Required:**

```dpug
@stateful
class Calculator
  @listen double result = 0

  void add(double a, double b) =>
    result = a + b

  Widget get build =>
    Text
      ..text: "Result: $result"
```

## IDE & Tooling Gaps

### 7. Unified CLI Architecture 🏆 HIGH PRIORITY

**Current State:** Fragmented CLI tools across multiple packages with no unified user experience

**Problem:**

- Users need to navigate between different package directories
- No single entry point for DPUG functionality
- Inconsistent command patterns across packages
- Poor discoverability of available tools

**Proposed Solution:** Create `dpug_cli` package with unified commands

**Architecture:**

```
dpug_cli/
├── lib/
│   ├── commands/
│   │   ├── format_command.dart
│   │   ├── convert_command.dart
│   │   └── server_command.dart
│   └── dpug_cli.dart
├── bin/
│   └── dpug.dart
└── pubspec.yaml
```

**User Experience:**

```bash
# One-time setup
dart pub global activate dpug

# Format files
dpug format path/to/file.dpug
dpug format path/to/directory/

# Convert between formats
dpug convert --from=path/to/file.dpug --to=path/to/file.dart
dpug convert --from=path/to/file.dart --to=path/to/file.dpug

# Server management
dpug server start --port=8080
dpug server stop
dpug server health

# Help and discovery
dpug --help
dpug format --help
dpug convert --help
```

**Benefits:**

- **Single Tool**: One command for all DPUG operations
- **Consistent Interface**: Unified command patterns
- **Better UX**: Follows common CLI tool conventions
- **Easy Installation**: `dart pub global activate dpug`
- **Discoverability**: Built-in help and command listing

**Implementation Strategy:**

1. Create `dpug_cli` package with `args` dependency
2. Forward commands to existing executables:
   - `format` → `dpug_core/bin/dpug_format.dart`
   - `server` → `dpug_server/bin/server.dart`
3. Add unified error handling and logging
4. Provide consistent help and version info

**Priority:** HIGH - This would dramatically improve the user experience and make DPUG more accessible to developers.

### 8. Language Server Features

**Stub Implementations:**

- Go to definition returns `null`
- Find references returns empty array
- Basic completion but limited context awareness

**Required:**

```typescript
// Should provide actual definitions
connection.onDefinition((params) => {
  // Search through codebase for symbol definitions
  return findDefinition(params.textDocument.uri, params.position);
});
```

### 9. CLI Tools (Enhanced)

**Status:** Basic CLI tools exist but need integration into unified architecture

**Current CLI Tools:**

- `dpug_core/bin/dpug_format.dart` - Basic formatting functionality
- `dpug_server/bin/server.dart` - Server management

**Missing Enhancements:**

- Integration with unified `dpug_cli` architecture
- Enhanced conversion commands with file I/O
- Batch processing capabilities
- Error handling improvements
- Progress indicators for large files

**Enhanced User Experience:**

```bash
# Format single file
dpug format input.dpug

# Format directory recursively
dpug format src/ --recursive

# Convert with file I/O (no piping needed)
dpug convert --from=input.dpug --to=output.dart
dpug convert --from=input.dart --to=output.dpug

# Batch conversion
dpug convert --from=src/*.dpug --to=lib/generated/
dpug convert --from=lib/*.dart --to=src/dpug/

# Server with better UX
dpug server start --port=8080 --host=localhost
dpug server logs --follow
dpug server stop --force
```

### 10. Advanced IntelliSense

**Missing:**

- Context-aware completions
- Parameter hints for widget properties
- Import suggestions
- Widget property autocompletion

## Testing & Quality Gaps

### 11. Comprehensive Test Coverage

**Missing:**

- Error case testing
- Edge case validation
- Performance testing
- Memory leak testing

**Required:**

```dart
group('Error Handling', () {
  test('Malformed indentation throws parse error', () {
    // Test cases for various syntax errors
  });

  test('Unknown annotations throw validation error', () {
    // Test invalid annotations
  });
});
```

### 11. Golden Tests

**Missing:**

- Regression testing framework
- Expected output validation
- Cross-version compatibility testing

**Required:**

```dart
// Golden test pattern
void main() {
  testGoldens('Basic stateful widget', (final tester) async {
    const dpug = '''
@stateful
class Counter
  @listen int count = 0
  Widget get build => Text..text: "Count"
''';

    await tester.convert(dpug);
    await tester.expectGolden('counter_basic');
  });
}
```

## Performance & Scalability Gaps

### 12. Caching & Optimization

**Missing:**

- AST caching for repeated conversions
- Incremental parsing
- Memory optimization for large files
- Parallel processing capabilities

### 13. Error Recovery

**Missing:**

- Graceful handling of partial syntax errors
- Recovery suggestions
- Multiple error reporting
- Partial AST construction for incomplete code

## Documentation & Ecosystem Gaps

### 14. Language Specification

**Missing:**

- Formal grammar specification
- Operator precedence rules
- Escaping rules
- Reserved keywords list

### 15. Developer Experience

**Missing:**

- Interactive playground
- Code examples library
- Migration guides
- Best practices documentation

## Priority Implementation Order

### Phase 1: UX Foundation (Week 1-2) 🏆 HIGHEST PRIORITY

1. **Create `dpug_cli` unified package** - Single entry point for all DPUG functionality
2. Fix parser validation and error handling
3. Fix code generation formatting issues
4. Implement proper exception throwing for invalid syntax

### Phase 2: Core Language (Week 3-4)

1. Add comments support
2. Implement basic control flow
3. Add map/collection syntax

### Phase 3: Tooling Enhancement (Week 5-6)

1. **Enhance CLI tools with unified architecture** - Integrate existing tools into dpug_cli
2. Fix language server go-to-definition
3. Add comprehensive IntelliSense

### Phase 4: Quality (Week 7-8)

1. Add comprehensive test coverage
2. Implement golden testing
3. Performance optimizations

This feature gaps analysis provides a clear roadmap for completing the DPUG language implementation and ensuring it meets production-ready standards.
