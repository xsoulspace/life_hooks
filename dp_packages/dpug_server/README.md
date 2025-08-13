# DPug Server

A simple `shelf`-based HTTP server that exposes the DPug-to-Dart and Dart-to-DPug conversion functionalities through a REST API. This is intended to be used by IDE extensions, such as a VS Code extension, to provide real-time conversion and formatting.

## How to Run

To start the server, run the following command from the `dpug_server` directory:

```bash
dart run bin/server.dart
```

## Endpoints

- `POST /dpug/to-dart`: Converts a DPug string to Dart.
  - **Request Body**: DPug code as `text/plain`.
  - **Response Body**: Dart code as `text/plain`.
- `POST /dart/to-dpug`: Converts a Dart string to DPug.
  - **Request Body**: Dart code as `text/plain`.
  - **Response Body**: DPug code as `text/plain`.
- `GET /health`: Returns `ok` for liveness checks.

## Error Handling

Errors are returned as YAML-shaped text in the response body with the following keys:

- `error`: The type of error (e.g., `DartToDpugError`).
- `message`: A description of the error.
- `span`: The location of the error in the source code (e.g., `"1:1..1:1"`).

**Example Error Response:**

```yaml
error: DartToDpugError
message: description of the error
span: "1:1..1:1"
```

## Examples

### DPug to Dart

```bash
curl -s -X POST localhost:8080/dpug/to-dart \
  -H 'Content-Type: text/plain' \
  --data-binary '@stateful\nclass TodoList\n  @listen String name = \'\'\n  Widget get build =>\n    Text\n      .."Hi"'
```

### Dart to DPug

```bash
curl -s -X POST localhost:8080/dart/to-dpug \
  -H 'Content-Type: text/plain' \
  --data-binary 'class A extends StatefulWidget { A({required this.name, super.key}); final String name; @override State<A> createState() => _AState(); } class _AState extends State<A> { @override Widget build(BuildContext context) { return Text("Hi"); } }'
```

```