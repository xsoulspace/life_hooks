# DPUG Annotation Plugin System

## Overview

DPUG now features a powerful plugin system that makes annotations truly extensible and developer-friendly. This addresses the fundamental issue where `@listen` was hardcoded into the language, making it feel like a language feature rather than a meta plugin.

## The Problem with Hardcoded Annotations

Previously, DPUG had hardcoded support for annotations like `@stateful` and `@listen`:

```dpug
@stateful  // Hardcoded in the compiler
class Counter
  @listen int count = 0  // Hardcoded in the compiler
```

This approach had several problems:

1. **Limited extensibility**: Only `@stateful` and `@listen` were supported
2. **Language bloat**: New features required compiler changes
3. **Poor developer experience**: Couldn't create custom annotations
4. **Tight coupling**: Business logic mixed with language implementation

## The Plugin Solution

The new plugin system treats annotations as meta plugins:

```dpug
@stateful  // Now handled by StatefulPlugin
class Counter
  @observable @persist String username = 'guest'  // Custom plugins
  @listen int count = 0  // Now handled by ListenPlugin
```

## Architecture

### Core Components

1. **`AnnotationPlugin` Interface**: Defines how plugins handle annotations
2. **`AnnotationPluginRegistry`**: Manages registered plugins
3. **Plugin Processing Pipeline**: Validates and processes annotations during compilation

### Plugin Interface

```dart
abstract class AnnotationPlugin {
  String get annotationName;  // The annotation this plugin handles (without @)

  // Validation and preprocessing
  void processClassAnnotation({...});
  void processFieldAnnotation({...});

  // Code generation
  Spec? generateClassCode({...});
  Spec? generateFieldCode({...});
}
```

## Built-in Plugins

### StatefulPlugin (`@stateful`)

Handles stateful widget generation with automatic state class creation.

```dpug
@stateful
class Counter
  @listen int count = 0
```

### StatelessPlugin (`@stateless`)

Handles stateless widget generation. Automatically validates that no state fields are present.

```dpug
@stateless
class DisplayWidget
  Widget get build =>
    Container
      ..padding: EdgeInsets.all(16)
      Text
        ..'Hello World'
```

### ListenPlugin (`@listen`)

Creates reactive state with getter/setter pairs that automatically call `setState()`.

```dpug
@listen int count = 0  // Generates: int get count => _count; set count(int value) => setState(() => _count = value);
```

### ChangeNotifierPlugin (`@changeNotifier`)

Creates ChangeNotifier-based state management with automatic disposal in stateful widgets.

**Key Feature**: When used in `@stateful` widgets, automatically generates `dispose()` calls for all ChangeNotifier fields.

```dpug
@stateful
class MyWidget
  @changeNotifier MyChangeNotifier model = MyChangeNotifier()

  Widget get build =>
    Text
      ..'Value: ${model.value}'

// Automatically generates in the state class:
@override
void dispose() {
  _disposeMODEL();  // Calls model.dispose()
  super.dispose();
}
```

## Creating Custom Plugins

### Example 1: ChangeNotifier Plugin

```dart
class ChangeNotifierPlugin implements AnnotationPlugin {
  @override
  String get annotationName => 'changeNotifier';

  @override
  void processFieldAnnotation({
    required String annotationName,
    required StateVariable field,
    required ClassNode classNode,
    required DpugConverter converter,
  }) {
    print('Setting up ChangeNotifier field: ${field.name}');
  }

  @override
  Spec? generateFieldCode({
    required String annotationName,
    required StateVariable field,
    required ClassNode classNode,
    required Map<String, dynamic> context,
  }) {
    return Code('''
      // ChangeNotifier field implementation
      late final ${field.type} _${field.name}Notifier = ${field.type}();

      ${field.type} get ${field.name} => _${field.name}Notifier;

      // Auto-dispose logic for stateful widgets
      void _dispose${field.name.toUpperCase()}() {
        _${field.name}Notifier.dispose();
      }
    ''');
  }

  @override
  Spec? generateClassCode({
    required String annotationName,
    required ClassNode classNode,
    required Map<String, dynamic> context,
  }) {
    // Check if this is a stateful widget and generate dispose logic
    final hasStatefulAnnotation = classNode.annotations.contains('stateful');
    if (hasStatefulAnnotation) {
      final changeNotifierFields = classNode.stateVariables
          .where((field) => field.annotation == 'changeNotifier')
          .map((field) => field.name)
          .toList();

      if (changeNotifierFields.isNotEmpty) {
        return Code('''
          // Auto-generated dispose logic for @changeNotifier fields
          @override
          void dispose() {
            ${changeNotifierFields.map((name) => '_dispose${name.toUpperCase()}();').join('\n            ')}
            super.dispose();
          }
        ''');
      }
    }
    return null;
  }
}
```

Usage:

```dpug
@stateful
class MyWidget
  @changeNotifier MyChangeNotifier model = MyChangeNotifier()
```

### Example 2: Stateless Plugin

```dart
class StatelessPlugin implements AnnotationPlugin {
  @override
  String get annotationName => 'stateless';

  @override
  void processClassAnnotation({
    required String annotationName,
    required ClassNode classNode,
    required DpugConverter converter,
  }) {
    print('Processing @stateless annotation for class ${classNode.name}');
    // Validate that this class doesn't have state fields
    if (classNode.stateVariables.isNotEmpty) {
      throw StateError('@stateless classes cannot have state fields. Use @stateful instead.');
    }
  }

  @override
  Spec? generateClassCode({
    required String annotationName,
    required ClassNode classNode,
    required Map<String, dynamic> context,
  }) {
    // Return a special marker that indicates this should generate stateless code
    return Code('__STATELESS_WIDGET__');
  }
}
```

Usage:

```dpug
@stateless
class DisplayWidget
  Widget get build =>
    Container
      ..padding: EdgeInsets.all(16)
      Text
        ..'Hello World'
```

### Example 3: Persistence Plugin

```dart
class PersistPlugin implements AnnotationPlugin {
  @override
  String get annotationName => 'persist';

  @override
  Spec? generateFieldCode({
    required String annotationName,
    required StateVariable field,
    required ClassNode classNode,
    required Map<String, dynamic> context,
  }) {
    return Code('''
      // Persistent field implementation
      ${field.type} get ${field.name} {
        return _prefs.get('${field.name}') ?? ${field.initializer ?? 'null'};
      }

      set ${field.name}(${field.type} value) {
        _${field.name}Value = value;
        _prefs.set('${field.name}', value);
      }
    ''');
  }
}
```

Usage:

```dpug
@stateful
class UserProfile
  @persist String username = 'guest'
  @persist bool notifications = true
```

## Plugin Registration

```dart
void main() {
  // Get the plugin registry
  final registry = AnnotationPluginRegistry();

  // Register custom plugins
  registry.registerPlugin(ChangeNotifierPlugin());
  registry.registerPlugin(PersistPlugin());

  // Now these annotations can be used in DPUG code
  const dpugCode = '''
  @stateful
  class MyWidget
    @changeNotifier @persist String username = 'guest'
    @listen int counter = 0
  ''';

  final converter = DpugConverter();
  final dartCode = converter.dpugToDart(dpugCode);
}
```

## Plugin Composition

Plugins can be composed together for complex behavior:

```dpug
@stateful
class AdvancedWidget
  @changeNotifier @persist String email = ''
  @listen int counter = 0

@stateless
class DisplayWidget
  Widget get build =>
    Text
      ..'Email: $email'
```

Each annotation is processed independently, allowing for rich combinations of behavior.

## Automatic Resource Management

The plugin system includes smart resource management features:

### ChangeNotifier Disposal

When using `@changeNotifier` in `@stateful` widgets, the plugin system automatically generates disposal logic:

```dpug
@stateful
class MyWidget
  @changeNotifier MyModel model = MyModel()

  Widget get build =>
    Text
      ..'Value: ${model.value}'
```

**Automatically generates:**

```dart
@override
void dispose() {
  _disposeMODEL();  // Calls model.dispose()
  super.dispose();
}
```

This prevents memory leaks and follows Flutter best practices.

### Validation

The `@stateless` plugin automatically validates that no state fields are present:

```dpug
@stateless
class MyWidget
  @listen int counter = 0  // ❌ Compile error: @stateless cannot have state fields
```

This ensures architectural consistency and prevents common mistakes.

## Benefits

1. **Extensibility**: Developers can create any annotations they need
2. **Separation of Concerns**: Language vs. business logic are clearly separated
3. **Reusability**: Plugins can be shared across projects
4. **Testability**: Each plugin can be tested independently
5. **Backwards Compatibility**: Existing `@stateful` and `@listen` continue to work
6. **Community Ecosystem**: Enables a marketplace of community-created plugins
7. **Automatic Resource Management**: Prevents memory leaks with automatic disposal
8. **Validation**: Built-in validation ensures architectural consistency
9. **Composability**: Multiple annotations can work together seamlessly
10. **Flutter Best Practices**: Enforces proper patterns like ChangeNotifier disposal

## Migration Guide

### From Hardcoded Annotations

**Old syntax (still works):**

```dpug
@stateful
class Counter
  @listen int count = 0
```

**New extensible syntax:**

```dpug
@stateful
class Counter
  @changeNotifier CounterModel model = CounterModel()  // More powerful state management
  @listen int legacyField = 0  // Still works for backwards compatibility

@stateless
class DisplayWidget
  Widget get build =>
    Text
      ..'Count: ${model.count}'
```

## Best Practices

1. **Naming**: Use descriptive annotation names that clearly indicate their purpose
2. **Documentation**: Document what each plugin does and how to use it
3. **Testing**: Create comprehensive tests for custom plugins
4. **Versioning**: Consider semantic versioning for plugin compatibility
5. **Error Handling**: Provide clear error messages when validation fails

## Future Enhancements

1. **Plugin Marketplace**: A central registry for community plugins
2. **Plugin Dependencies**: Allow plugins to depend on other plugins
3. **Configuration**: Allow plugins to be configured via external config files
4. **IDE Integration**: Enhanced autocomplete and validation for custom plugins
5. **Performance**: Caching and optimization for plugin code generation

This plugin system transforms DPUG from a language with hardcoded features into a truly extensible platform where developers can create their own meta-programming constructs tailored to their specific needs.
