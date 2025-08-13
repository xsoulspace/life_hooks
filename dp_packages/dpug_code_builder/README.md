# DPug Code Builder

This package provides a programmatic API for building DPug and Dart code. It uses a system of "specs" and "builders" to construct code, similar to the official Dart `code_builder` package.

## Features

- **Programmatic Code Generation**: Build DPug and Dart code using a fluent API.
- **Builders**: High-level builders for creating classes and widgets.
- **Specs**: Low-level specifications for fine-grained control over the generated code.
- **Visitors**: A visitor pattern for traversing the spec tree and generating code.

## Usage

This package is intended to be used by other packages in the DPug project, such as `dpug_core`. It can also be used to programmatically generate DPug or Dart code.

### Creating a Stateful Widget

```dart
final widget = Dpug.classBuilder()
  ..name('MyWidget')
  ..annotation(DpugAnnotationSpec.stateful())
  ..listenField(
    name: 'count',
    type: 'int',
    initializer: DpugExpressionSpec.literal(0),
  )
  ..buildMethod(
    body: WidgetHelpers.column(
      children: [
        // Add children here
      ],
    ),
  );
```

### Using Widget Helpers

```dart
WidgetHelpers.column(
  properties: {
    'mainAxisAlignment': DpugExpressionSpec.reference('MainAxisAlignment.center'),
  },
  children: [
    // Add children here
  ],
)
```