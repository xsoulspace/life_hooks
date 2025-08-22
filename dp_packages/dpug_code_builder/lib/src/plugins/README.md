# Unified Plugin System

The Unified Plugin System provides a single, cohesive way to handle DPUG plugin functionality across all contexts (compiler, visitors, formatters, etc.).

## Overview

Previously, DPUG had multiple separate plugin systems:

- `AnnotationPlugin` in `dpug_core` for compiler plugins
- `DpugToDartPlugin` in `dpug_code_builder` for DPug → Dart conversion
- `DartToDpugPlugin` in `dpug_code_builder` for Dart → DPug conversion

This led to code duplication, maintenance burden, and inconsistency. The Unified Plugin System consolidates all plugin functionality into a single system.

## Architecture

### Core Components

1. **`UnifiedPlugin`** - Base interface for all plugins
2. **`ClassPlugin`** - For class-level annotations (@stateful, @stateless)
3. **`FieldPlugin`** - For field-level annotations (@listen, @changeNotifier)
4. **`UnifiedPluginRegistry`** - Singleton registry managing all plugins
5. **`dpugCorePluginRegistry`** - Compatibility layer for dpug_core

### Plugin Priority System

Plugins have priorities to control execution order:

- `@stateful`: 100 (highest priority)
- `@stateless`: 90
- `@listen`: 80
- `@changeNotifier`: 70
- Custom plugins: 50 (default)

## Usage

### For Plugin Developers

#### Creating a Custom Plugin

```dart
import 'package:dpug_code_builder/src/plugins/plugins.dart';

class MyCustomPlugin extends ClassPlugin {
  const MyCustomPlugin();

  @override
  String get annotationName => 'myCustom';

  @override
  int get priority => 50;

  @override
  void processClassAnnotation({
    required String annotationName,
    required dynamic classNode,
    final dynamic converter,
  }) {
    print('Processing @myCustom annotation');
  }

  @override
  cb.Spec? generateClassCode({
    required String annotationName,
    required dynamic classNode,
    required Map<String, dynamic> context,
  }) {
    // Your custom code generation logic
    return null;
  }
}

// Register your plugin
registerPlugin(const MyCustomPlugin());
```

#### Field-Level Plugin Example

```dart
class MyFieldPlugin extends FieldPlugin {
  const MyFieldPlugin();

  @override
  String get annotationName => 'myFieldAnnotation';

  @override
  cb.Spec? generateFieldCode({
    required String annotationName,
    required dynamic field,
    required dynamic classNode,
    required Map<String, dynamic> context,
  }) {
    final isStateClass = context['isStateClass'] as bool? ?? false;

    if (isStateClass) {
      return cb.Field(
        (final b) => b
          ..name = '_${field.name}'
          ..type = cb.refer('String')
          ..assignment = cb.Code('"default value"'),
      );
    }
    return null;
  }
}
```

### For Users

The core plugins are automatically registered:

- `@stateful` - Creates StatefulWidget classes
- `@stateless` - Creates StatelessWidget classes
- `@listen` - Creates reactive state fields
- `@changeNotifier` - Creates ChangeNotifier fields

### Checking Plugin Support

```dart
import 'package:dpug_code_builder/src/plugins/plugins.dart';

// Check if annotation is supported
bool supported = isAnnotationSupported('stateful'); // true

// Get plugin instance
UnifiedPlugin? plugin = getPlugin('listen');
```

## Migration Guide

### From Old dpug_core Plugin System

**Before:**

```dart
// In dpug_core
class MyPlugin implements AnnotationPlugin {
  // Implementation
}

final registry = AnnotationPluginRegistry();
registry.registerPlugin(MyPlugin());
```

**After:**

```dart
// Use unified system
class MyPlugin extends UnifiedPlugin {
  // Implementation
}

registerPlugin(const MyPlugin());
```

### From Old dpug_code_builder Plugin Systems

**Before:**

```dart
// Dart to DPug conversion
class MyPlugin implements DartToDpugPlugin {
  // Implementation
}

final registry = DartToDpugPluginRegistry();
registry.registerPlugin(MyPlugin());
```

**After:**

```dart
// Use unified system
class MyPlugin extends UnifiedPlugin {
  // Implementation with processClassForDpug/processFieldForDpug methods
}

registerPlugin(const MyPlugin());
```

## Benefits

1. **Single Source of Truth** - All plugin logic in one place
2. **Reduced Duplication** - No more duplicate plugin implementations
3. **Consistent API** - Unified interface across all contexts
4. **Easy Registration** - Simple `registerPlugin()` function
5. **Priority System** - Control execution order
6. **Backward Compatibility** - Existing code continues to work
7. **Better Testing** - Single test suite for all plugin functionality
8. **Easier Maintenance** - One system to maintain instead of three

## Testing

Run the unified plugin system tests:

```bash
dart test test/unified_plugin_system_test.dart
```

## File Structure

```
dpug_code_builder/lib/src/plugins/
├── plugins.dart                    # Main exports
├── unified_plugin_system.dart      # Core interfaces and registry
├── core_plugins.dart              # Core plugin implementations
├── plugin_registration.dart       # Simple registration functions
├── dpug_core_compatibility.dart   # Compatibility layer for dpug_core
└── README.md                      # This file
```
