// DPug Language Specification

Welcome to the comprehensive DPug language specification. DPug is a Pug-inspired, indentation-based syntax for Flutter/Dart that provides a more concise and readable way to write Flutter widgets while maintaining full compatibility with the existing Dart/Flutter ecosystem.

## Overview

DPug transforms traditional Dart/Flutter code:

```dart
class MyWidget extends StatelessWidget {
  final String title;
  final int count;

  const MyWidget({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          Text('Count: $count'),
        ],
      ),
    );
  }
}
```

Into clean, indentation-based syntax:

```dpug
@stateless
class MyWidget
  String title
  int count

  MyWidget({required this.title, required this.count})

  Widget get build =>
    Container
      padding: EdgeInsets.all(16.0)
      child:
        Column
          children:
            Text
              title
              style:
                TextStyle
                  fontSize: 24.0
                  fontWeight: FontWeight.bold
            Text 'Count: $count'
```

## Specification Structure

This specification is organized into focused modules:

### Core Language Features

- **[Primitives](./dpug_primitives.md)** - Numbers, strings, booleans, null safety
- **[Collections](./dpug_collections.md)** - Lists, maps, sets, and iteration
- **[Classes](./dpug_classes.md)** - Classes, inheritance, methods, constructors
- **[Advanced Features](./dpug_advanced.md)** - Imports, exports, async/await, patterns

### Meta-Programming & Flutter

- **[Annotations](./dpug_annotations.md)** - Metadata, dependency injection, validation
- **[Flutter Integration](./dpug_flutter.md)** - Widgets, state management, theming

## Key Language Concepts

### Indentation-Based Syntax

DPug uses indentation (2 spaces) instead of braces, inspired by Python and Pug:

```dpug
class User
  String name
  int age

  void greet() => print 'Hello, $name!'
```

### Widget Sugar

Automatic child/children inference for Flutter widgets:

```dpug
Column
  Text 'First item'
  Text 'Second item'
  ElevatedButton
    onPressed: () => print 'Pressed'
    child: Text 'Click me'
```

### Cascade Syntax

Clean property setting with Dart's cascade operator:

```dpug
Container
  padding: EdgeInsets.all(16.0)
  decoration:
    BoxDecoration
      color: Colors.blue
      borderRadius: BorderRadius.circular(8.0)
  child: Text 'Hello'
```

### State Management Annotations

Built-in support for reactive state:

```dpug
@stateful
class Counter
  @changeNotifier int count = 0

  void increment() => count++

  Widget get build =>
    Text '$count'
```

## Quick Start Examples

### Basic Widget

```dpug
@stateless
class HelloWidget
  Widget get build =>
    Center
      child: Text 'Hello, DPug!'
```

### Stateful Counter

```dpug
@stateful
class CounterWidget
  @changeNotifier int count = 0

  void increment() => count++

  Widget get build =>
    Column
      children:
        Text 'Count: $count'
        ElevatedButton
          onPressed: increment
          child: Text 'Increment'
```

### Form with Validation

```dpug
@stateful
class LoginForm
  @changeNotifier String email = ''
  @changeNotifier String password = ''

  Widget get build =>
    Column
      children:
        TextField
          onChanged: (value) => email = value
          decoration: InputDecoration labelText: 'Email'
        TextField
          onChanged: (value) => password = value
          decoration: InputDecoration labelText: 'Password'
        ElevatedButton
          onPressed: () => login()
          child: Text 'Login'
```

## Language Philosophy

DPug is designed with these core principles:

1. **Readability First** - Code should be easy to read and understand
2. **Minimal Ceremony** - Reduce boilerplate while maintaining clarity
3. **Flutter-Native** - First-class support for Flutter's widget system
4. **Dart Compatible** - Full interoperability with existing Dart code
5. **Progressive Enhancement** - Easy migration path from Dart to DPug

## Tooling Support

DPug is supported by a comprehensive toolchain:

- **VS Code Extension** - Syntax highlighting, completion, formatting
- **CLI Tools** - Convert between DPug ↔ Dart, format code
- **Language Server** - IDE features and diagnostics
- **HTTP API** - Server for editors and automation

## Migration Guide

Converting existing Flutter code to DPug is straightforward:

1. Replace `extends StatelessWidget` with `@stateless`
2. Replace `extends StatefulWidget` with `@stateful`
3. Use indentation instead of braces
4. Remove `build(BuildContext context)` method signature
5. Use cascade syntax (`..property:`) for widget properties
6. Leverage automatic child/children inference

## Contributing

The DPug specification is a living document. To contribute:

1. Fork the repository
2. Make your changes to the appropriate specification file
3. Test examples with the DPug compiler
4. Submit a pull request with clear description

## Examples Repository

For more comprehensive examples, see the [dpug_cli/example](../dpug_cli/example/) directory, which contains:

- Basic widgets and state management
- Form handling and validation
- Complex layouts and animations
- Integration with popular Flutter packages

---

**Note**: This specification assumes familiarity with Dart and Flutter concepts. For complete beginners, it's recommended to first learn Dart and Flutter fundamentals before diving into DPug.
