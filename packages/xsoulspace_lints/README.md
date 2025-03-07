# Intro

Hi!

This is a set of rules which I use for my personal and commercial projects.

Usually, I review these rules once a year and update them based on the latest Flutter and Dart releases.

Hope this helps! :)

# Available rules:

- `app.yaml` - useful for developing application or its parts.
- `library.yaml` - useful for monorepos.
- `public_library.yaml` - the purpose to use this lint if you developing a library which will be published to pub.dev.

# Usage:

1. Add dependecies for pubspec:

```yaml
dev_dependencies:
  lints: [latest_version]
  xsoulspace_lints: [latest_version]
```

2. Then place in the `analysis_options.yaml`

```yaml
include: package:xsoulspace_lints/[filename].yaml
```

For example:

```yaml
include: package:xsoulspace_lints/app.yaml
```
