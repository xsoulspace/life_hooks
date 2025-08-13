# Writing Tests

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
