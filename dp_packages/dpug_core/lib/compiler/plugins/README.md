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

### ListenPlugin (`@listen`)

Creates reactive state with getter/setter pairs that automatically call `setState()`.

```dpug
@listen int count = 0  // Generates: int get count => _count; set count(int value) => setState(() => _count = value);
```

## Creating Custom Plugins

### Example 1: Observable Plugin

```dart
class ObservablePlugin implements AnnotationPlugin {
  @override
  String get annotationName => 'observable';

  @override
  void processFieldAnnotation({
    required String annotationName,
    required StateVariable field,
    required ClassNode classNode,
    required DpugConverter converter,
  }) {
    print('Setting up observable field: ${field.name}');
  }

  @override
  Spec? generateFieldCode({
    required String annotationName,
    required StateVariable field,
    required ClassNode classNode,
    required Map<String, dynamic> context,
  }) {
    return Code('''
      // Observable field implementation
      late final StreamController<${field.type}> _${field.name}Controller = StreamController.broadcast();

      Stream<${field.type}> get ${field.name}Stream => _${field.name}Controller.stream;

      ${field.type} get ${field.name} => _${field.name}Value;
      set ${field.name}(${field.type} value) {
        _${field.name}Value = value;
        _${field.name}Controller.add(value);
      }
    ''');
  }
}
```

Usage:

```dpug
@stateful
class MyWidget
  @observable String status = 'idle'
```

### Example 2: Persistence Plugin

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
  registry.registerPlugin(ObservablePlugin());
  registry.registerPlugin(PersistPlugin());

  // Now these annotations can be used in DPUG code
  const dpugCode = '''
  @stateful
  class MyWidget
    @observable @persist String username = 'guest'
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
  @observable @persist @validate String email = ''
  @computed double score
```

Each annotation is processed independently, allowing for rich combinations of behavior.

## Benefits

1. **Extensibility**: Developers can create any annotations they need
2. **Separation of Concerns**: Language vs. business logic are clearly separated
3. **Reusability**: Plugins can be shared across projects
4. **Testability**: Each plugin can be tested independently
5. **Backwards Compatibility**: Existing `@stateful` and `@listen` continue to work
6. **Community Ecosystem**: Enables a marketplace of community-created plugins

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
  @observable int count = 0  // Using custom observable plugin
  @listen int legacyField = 0  // Still works for backwards compatibility
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
