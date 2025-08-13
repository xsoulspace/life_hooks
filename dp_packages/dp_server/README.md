# DPug Conversion Server

Minimal HTTP service exposing DPug <-> Dart endpoints.

## Run

```bash
dart run bin/server.dart
```

## Endpoints

- POST `/dpug/to-dart` (text/plain body) → returns Dart (text/plain)
- POST `/dart/to-dpug` (text/plain body) → returns DPug (text/plain)

## Error format (YAML)

```
error: <Type>
message: <string>
span: "<line>:<column>..<line>:<column>"
```

## Examples

```bash
curl -s -X POST localhost:8080/dpug/to-dart \
  -H 'Content-Type: text/plain' \
  --data-binary $'@stateful\nclass TodoList\n  @listen String name = \''\n  Widget get build =>\n    Text\n      ..\'Hi\''
```

```bash
curl -s -X POST localhost:8080/dart/to-dpug \
  -H 'Content-Type: text/plain' \
  --data-binary $'class A extends StatefulWidget { A({required this.name, super.key}); final String name; @override State<A> createState() => _AState(); } class _AState extends State<A> { @override Widget build(BuildContext context) { return Text(\'Hi\'); } }'
```
