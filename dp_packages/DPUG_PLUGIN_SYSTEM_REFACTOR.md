# DPUG Plugin System Refactor

## Problem Statement

The original user feedback identified a fundamental issue with DPUG's annotation system:

> "we have wrong syntax in dpug_test. when we define in dpug: @listen that means we listen the argument of the class in stateful or in stateless widgets. I think it is fundamental problem because these annotations are not exactly dpug they should be like meta plugins for dpug and flutter, so every developer could create his own"

## Issues with the Original Approach

### 1. **Hardcoded Language Features**

- `@listen` was hardcoded into the DPUG compiler
- `@stateful` was hardcoded into the DPUG grammar
- No way for developers to create custom annotations

### 2. **Poor Semantics**

- `@listen` didn't clearly indicate what it actually does
- No clear separation between language features and meta-programming constructs

### 3. **Limited Extensibility**

- Adding new annotations required compiler changes
- No plugin ecosystem for community contributions

### 4. **Missing Flutter Best Practices**

- No automatic resource management (e.g., ChangeNotifier disposal)
- No architectural validation (e.g., stateless widgets with state fields)

## Solution: Plugin System Architecture

### Core Changes

#### 1. **Generic Annotation Grammar**

```dart
// Before: Hardcoded grammar rules
Parser stateField() =>
  (ref(annotation) &  // Only @listen allowed
      ref(typeAnnotation).optional() &
      ref(identifier) &
      ref(equals).optional() &
      ref(expression).optional())
      .map((final values) => values);

// After: Generic annotation support
Parser annotation() => (char('@') & ref(identifier)).flatten();  // Any @annotation
```

#### 2. **Plugin-Based Processing**

```dart
// Before: Hardcoded validation
void _validateAnnotation(final String annotationName, final Token token) {
  const Set<String> validAnnotations = {'stateful', 'listen'};
  if (!validAnnotations.contains(annotationName)) {
    throw StateError('Unknown annotation "@$annotationName"');
  }
}

// After: Plugin-based validation
void _validateAnnotation(final String annotationName, final Token token) {
  final registry = AnnotationPluginRegistry();
  if (!registry.isAnnotationSupported(annotationName)) {
    print('Warning: Unknown annotation "@$annotationName"');
    // Allow unknown annotations to pass through for custom plugins
  }
}
```

#### 3. **Plugin Interface**

```dart
abstract class AnnotationPlugin {
  String get annotationName;  // e.g., 'changeNotifier'

  // Validation and preprocessing
  void processClassAnnotation({...});
  void processFieldAnnotation({...});

  // Code generation
  Spec? generateClassCode({...});
  Spec? generateFieldCode({...});
}
```

### New Annotations and Features

#### 1. **@changeNotifier** (Replaces @listen)\*\*

```dpug
@stateful
class MyWidget
  @changeNotifier MyModel model = MyModel()
```

**Benefits:**

- Clear semantics: explicitly uses ChangeNotifier pattern
- Automatic disposal: generates `dispose()` calls automatically
- Better performance: follows Flutter best practices
- Memory safety: prevents resource leaks

**Generated Code:**

```dart
class _MyWidgetState extends State<MyWidget> {
  late final MyModel _modelNotifier = MyModel();

  MyModel get model => _modelNotifier;

  void _disposeMODEL() {
    _modelNotifier.dispose();
  }

  @override
  void dispose() {
    _disposeMODEL();
    super.dispose();
  }
}
```

#### 2. **@stateless** (New Feature)\*\*

```dpug
@stateless
class DisplayWidget
  Widget get build =>
    Text
      ..'Hello World'
```

**Benefits:**

- Architectural validation: prevents state fields in stateless widgets
- Clear intent: explicitly declares widget as stateless
- Compile-time safety: catches architectural mistakes early

**Validation:**

```dart
@stateless
class BadWidget
  @listen int counter = 0  // ❌ Compile error: @stateless cannot have state fields
```

#### 3. **Plugin Composition**

```dpug
@stateful
class AdvancedWidget
  @changeNotifier @persist String email = ''
  @listen int counter = 0
```

**Each plugin processes independently:**

- `@changeNotifier`: Generates ChangeNotifier field with disposal
- `@persist`: Adds persistence logic
- `@listen`: Creates reactive getter/setter

## Architecture Benefits

### 1. **True Extensibility**

```dart
// Developers can create any annotation they want
class ValidationPlugin implements AnnotationPlugin {
  @override
  String get annotationName => 'validate';

  // Custom validation logic
  @override
  void processFieldAnnotation(...) {
    // Add validation rules
  }
}

// Usage:
@stateful
class FormWidget
  @changeNotifier @validate String email = ''
```

### 2. **Separation of Concerns**

- **Language**: Generic annotation syntax (`@annotation`)
- **Plugins**: Business logic and code generation
- **Framework**: Flutter-specific patterns and best practices

### 3. **Automatic Resource Management**

```dpug
@stateful
class MyWidget
  @changeNotifier Model model = Model()
  @changeNotifier Service service = Service()
```

**Automatically generates:**

```dart
@override
void dispose() {
  _disposeMODEL();      // model.dispose()
  _disposeSERVICE();    // service.dispose()
  super.dispose();
}
```

### 4. **Architectural Validation**

```dpug
@stateless
class DisplayWidget
  @listen int counter = 0  // ❌ Compile error
```

### 5. **Backwards Compatibility**

```dpug
// Old syntax still works
@stateful
class Counter
  @listen int count = 0

// New syntax available
@stateful
class Counter
  @changeNotifier CounterModel model = CounterModel()

@stateless
class Display
  Widget get build => Text('Count: ${model.count}')
```

## Implementation Details

### Plugin Registration

```dart
final registry = AnnotationPluginRegistry();

// Register custom plugins
registry.registerPlugin(ChangeNotifierPlugin());
registry.registerPlugin(PersistPlugin());

// Now these annotations can be used in DPUG code
const dpugCode = '''
@stateful
class MyWidget
  @changeNotifier @persist String data = ''
''';
```

### Code Generation Pipeline

1. **Parse DPUG** → AST with generic annotations
2. **Validate** → Check plugins are registered
3. **Process** → Each plugin processes its annotations
4. **Generate** → Plugins generate specific code
5. **Combine** → Merge all generated code

### Error Handling

```dart
// Unknown annotations are warnings, not errors
@stateful
class MyWidget
  @unknownAnnotation String field = ''  // Warning: No plugin for @unknownAnnotation
```

## Migration Path

### Phase 1: Add Plugin System (Current)

- Implement plugin architecture
- Create built-in plugins
- Maintain backwards compatibility

### Phase 2: Deprecate Old Annotations (Future)

```dpug
// Old (deprecated but works)
@listen int count = 0

// New (recommended)
@changeNotifier CounterModel model = CounterModel()
```

### Phase 3: Community Ecosystem

- Plugin marketplace
- Community-contributed plugins
- Standard plugin patterns

## Benefits Summary

1. **Developer Freedom**: Create any annotations needed
2. **Memory Safety**: Automatic resource disposal
3. **Architectural Safety**: Validation prevents mistakes
4. **Performance**: Optimized code generation
5. **Community**: Shareable plugin ecosystem
6. **Future-Proof**: Extensible architecture
7. **Best Practices**: Enforces Flutter patterns
8. **Backwards Compatible**: Existing code continues to work

This refactor transforms DPUG from a language with hardcoded features into a truly extensible platform where developers can create their own meta-programming constructs tailored to their specific needs.
