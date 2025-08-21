# PetitParser Migration Guide for DPug

## Overview

This document outlines the migration from DPug's hand-written lexer/parser to PetitParser, including benefits, implementation approach, and integration strategy.

## Current Implementation Analysis

### Strengths

- **Custom Control**: Fine-grained control over parsing logic
- **Performance**: Direct implementation without abstraction overhead
- **Debugging**: Easy to debug with print statements and step-through
- **Simplicity**: No external dependencies for core parsing

### Limitations

- **Maintenance**: Changes require modifying complex recursive descent logic
- **Error Handling**: Basic error reporting with limited recovery
- **Testing**: Manual test creation for each grammar rule
- **Extensibility**: Adding new features requires significant code changes

## PetitParser Benefits

### 1. Declarative Grammar Definition

```dart
// PetitParser approach
Parser classDefinition() =>
  (ref(annotations).optional() &
   ref(keyword, 'class') &
   ref(identifier) &
   ref(colon) &
   ref(classBody).optional())
  .map((values) => ClassNode(...));
```

### 2. Built-in Error Handling & Recovery

- Automatic error position tracking
- Better error messages with context
- Parser composition for better error recovery

### 3. Enhanced Testing & Debugging

```dart
// Built-in linter for grammar validation
final issues = linter(parser);
expect(issues, isEmpty);

// Built-in tracing for debugging
trace(parser).parse(input);
```

### 4. Grammar Composition & Reusability

- Easy to compose complex parsers from simple ones
- Reusable parser components
- Dynamic grammar modification

## Migration Strategy

### Phase 1: Parallel Implementation

1. Add PetitParser dependency
2. Create new `DPugGrammar` class alongside existing lexer/parser
3. Implement grammar rules for core DPug syntax
4. Add comprehensive tests for new parser

### Phase 2: Feature Parity

1. Implement all current DPug features:
   - Class definitions with annotations
   - Widget trees with indentation
   - Properties and positional arguments
   - Expressions (literals, closures, assignments)
   - Source span tracking

### Phase 3: Integration

1. Create adapter layer for AST compatibility
2. Update `ASTBuilder` to work with new parser
3. Add migration tests to ensure identical output
4. Performance benchmarking

### Phase 4: Replacement

1. Switch default parser to PetitParser version
2. Keep old parser as fallback option
3. Update documentation and examples
4. Monitor performance and error rates

## Implementation Details

### Grammar Structure

- `DPugGrammar`: Main grammar definition class
- Modular rule definitions for each language construct
- Built-in whitespace and comment handling
- Indentation-aware parsing for widget trees

### AST Compatibility

- Maintains same AST node structure
- Preserves source span information
- Compatible with existing code generation pipeline
- No breaking changes to public APIs

### Error Handling

- Enhanced error messages with position information
- Better recovery for partial parses
- Detailed parsing failure diagnostics

## Performance Considerations

### PetitParser Advantages

- Packrat parsing for better performance on complex grammars
- Memoization reduces redundant parsing
- Efficient parsing of recursive structures

### Potential Trade-offs

- Initial parsing overhead for grammar construction
- Memory usage for memoization tables
- Abstraction layer performance cost

## Testing Strategy

### Grammar Testing

```dart
test('DPug grammar validation', () {
  final grammar = DPugGrammar();
  final parser = grammar.build();
  expect(linter(parser), isEmpty);
});
```

### Round-trip Testing

```dart
test('parser round-trip compatibility', () {
  final input = '@stateful\nclass Test\n  @listen int count = 0';
  final parser = DPugParser();
  final result = parser.parse(input);

  expect(result.isSuccess, true);
  expect(result.value, isA<ClassNode>());
});
```

## Benefits Summary

1. **Maintainability**: Declarative grammar is easier to understand and modify
2. **Reliability**: Built-in error handling and recovery mechanisms
3. **Testability**: Better testing tools and grammar validation
4. **Extensibility**: Easier to add new language features
5. **Debugging**: Enhanced debugging and tracing capabilities
6. **Community**: Leverages mature, well-tested parsing library

## Migration Timeline

- **Week 1-2**: Dependency addition and basic grammar implementation
- **Week 3-4**: Feature parity and comprehensive testing
- **Week 5-6**: Integration testing and performance optimization
- **Week 7-8**: Production deployment with monitoring

## Conclusion

Migrating to PetitParser will significantly improve DPug's parsing capabilities while maintaining backward compatibility. The declarative approach will make the codebase more maintainable and the enhanced error handling will provide better developer experience.

The migration should be approached systematically with thorough testing at each phase to ensure no regressions in functionality or performance.
