# DPug Docs (Architecture, Protocol, Plan)

DPug is a Pug-like, indentation-based syntax for Flutter/Dart with two-way conversion: DPug <-> Dart.

Packages

- dpug_core: lexer, parser, AST, transforms; DPug <-> Dart conversion, spans for diagnostics
- dpug_code_builder: IR/specs, builders, visitors; emit DPug text and generate Dart via code_builder
- dpug_server: Shelf HTTP service exposing conversion/formatting for editors (VS Code priority)

HTTP API (dpug_server)

- POST /dpug/to-dart: request text/plain (DPug), response text/plain (Dart)
- POST /dart/to-dpug: request text/plain (Dart), response text/plain (DPug)
- POST /format/dpug (optional): request text/plain (DPug), response text/plain (formatted DPug)
- GET /health: ok
- Errors (application/yaml): error, message, span (lineStart:colStart..lineEnd:colEnd)

Minimum Syntax

- Widgets as indented tree; automatic child/children sugar
- Properties via cascade: ..prop: value
- Positional args: cascade (..'Hello') and function call (Text('Hello'))
- Expressions: strings, numbers, bools, identifiers, closures (() => expr), simple assignments (a = b)
- State: @stateful class + @listen fields generate a Flutter State with getters/setters

Phased Plan

1. Editor MVP: unify package versions, precise spans, CORS + health + format endpoint, VS Code extension (convert/format, diagnostics)
2. Language depth: comments, multiline/raw strings, maps/lists/invocations/spread/if, named ctors; implement @state (ValueNotifier) distinct from @listen (setState)
3. Tooling: CLI (convert/format/serve), CI golden tests, docs & cookbook

Milestones

- Green round-trip tests for core patterns
- Stable formatting (compact/readable configs)
- Accurate span diagnostics end-to-end
