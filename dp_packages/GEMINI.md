## Project Overview

This project, DPug, is a code preprocessor and syntax extension for Flutter/Dart. It introduces a Pug-like, indentation-based syntax for defining Flutter widgets, aiming to simplify and streamline the UI development process. The core feature is the two-way conversion between the DPug syntax and standard Dart code.

The project is structured as a monorepo with the following packages:

- **`dpug_core`**: This is the heart of the project, containing the compiler with the lexer, parser, and Abstract Syntax Tree (AST) definitions. It handles the logic for converting DPug code to Dart and vice-versa.

- **`dpug_code_builder`**: This package provides a programmatic API for building DPug and Dart code. It uses a system of "specs" and "builders" to construct code, similar to the official Dart `code_builder` package.

- **`dpug_server`**: A simple `shelf`-based HTTP server that exposes the DPug-to-Dart and Dart-to-DPug conversion functionalities through a REST API. This is intended to be used by IDE extensions, such as a VS Code extension, to provide real-time conversion and formatting.

- **`dpug_docs`**: This directory contains project documentation, including architectural overviews and development plans.

## Goal

The primary goal of the DPug project is to offer a more concise and readable syntax for Flutter widget development, while ensuring full interoperability with the existing Dart ecosystem. The project aims to provide a seamless developer experience through robust tooling, including IDE integration for on-the-fly code conversion and formatting.

## How to Interact

The main entry point for using the DPug conversion functionality is the `dpug_server`. To start the server, run the following command from the `dpug_server` directory:

```bash
dart run bin/server.dart
```

The server exposes the following endpoints:

- `POST /dpug/to-dart`: Converts a DPug string to Dart.
- `POST /dart/to-dpug`: Converts a Dart string to DPug.

### Additional endpoint

- `GET /health`: Returns `ok` for liveness checks.

### Error handling

- Errors are returned as YAML-shaped text in the response body with keys: `error`, `message`, `span`.
- Current content type is `text/plain`.
- Example body:

```
error: DartToDpugError
message: description of the error
span: "1:1..1:1"
```

### Current limitations

- Dart → DPug supports a subset of StatefulWidget patterns (simple constructor args, basic widget trees).
- Complex expressions and advanced Flutter APIs may be emitted as raw source references.

### Conversion pipeline (high level)

- DPug → Dart: Lexer → AST → `AstToDart` → `DartWidgetCodeGenerator` → formatted Dart.
- Dart → DPug: Analyzer AST → minimal transformer → DPug text.
