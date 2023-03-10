Strict lint rules for Flutter and Dart.

- app.yaml - useful for developing application or its parts.
- library.yaml - useful for monorepos.
- public_library.yaml - the purpose to use this lint if you developing a library which will be published to pub.dev.

To include a library write:

```yaml
include: [filename].yaml
```

to analysis.yaml file in your project.

For example:

```yaml
include: app.yaml
```
