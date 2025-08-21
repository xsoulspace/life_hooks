import 'dart:io';

import 'package:dpug_server/server.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  late HttpServer server;

  setUp(() async {
    server = await serve(port: 0); // Use random available port
  });

  tearDown(() async {
    await server.close();
  });

  test('Health endpoint returns ok', () async {
    final port = server.port;
    final response = await http.get(Uri.parse('http://localhost:$port/health'));

    expect(response.statusCode, equals(200));
    expect(response.body, equals('ok'));
    expect(response.headers['content-type'], equals('text/plain'));
  });

  test('DPug to Dart conversion', () async {
    final port = server.port;
    const dpugCode = '''
@stateful
class Test
  @listen int count = 0

  Widget get build =>
    Text
      ..text: 'Hello'
''';

    final response = await http.post(
      Uri.parse('http://localhost:$port/dpug/to-dart'),
      headers: {'Content-Type': 'text/plain'},
      body: dpugCode,
    );

    expect(response.statusCode, equals(200));
    expect(response.headers['content-type'], contains('text/plain'));
    expect(response.body, contains('class Test extends StatefulWidget'));
    expect(response.body, contains('int _count = widget.count'));
  });

  test('Dart to DPug conversion', () async {
    final port = server.port;
    const dartCode = '''
class Test extends StatefulWidget {
  const Test({super.key});
  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Text('Hello');
  }
}
''';

    final response = await http.post(
      Uri.parse('http://localhost:$port/dart/to-dpug'),
      headers: {'Content-Type': 'text/plain'},
      body: dartCode,
    );

    expect(response.statusCode, equals(200));
    expect(response.headers['content-type'], equals('text/plain'));
    expect(response.body, contains('class Test'));
    expect(response.body, contains('Widget get build'));
  });

  test('Error handling for invalid DPug', () async {
    final port = server.port;
    const invalidDpug = r'''
@invalid
class Broken
  @broken syntax
  Widget get build =>
    @#$% invalid
''';

    final response = await http.post(
      Uri.parse('http://localhost:$port/dpug/to-dart'),
      headers: {'Content-Type': 'text/plain'},
      body: invalidDpug,
    );

    expect(response.statusCode, equals(400));
    expect(response.headers['content-type'], contains('text/plain'));
    expect(response.body, contains('error:'));
  });

  test('Error handling for invalid Dart', () async {
    final port = server.port;
    const invalidDart = '''
class Broken extends NotAWidget {
  void notAMethod() {
    return invalid;
  }
}
''';

    final response = await http.post(
      Uri.parse('http://localhost:$port/dart/to-dpug'),
      headers: {'Content-Type': 'text/plain'},
      body: invalidDart,
    );

    expect(response.statusCode, equals(400));
    expect(response.headers['content-type'], equals('text/plain'));
    expect(response.body, contains('error:'));
  });

  test('CORS headers are present', () async {
    final port = server.port;
    final response = await http.get(Uri.parse('http://localhost:$port/health'));

    expect(response.headers['access-control-allow-origin'], equals('*'));
    expect(
      response.headers['access-control-allow-methods'],
      equals('GET, POST, OPTIONS'),
    );
    expect(
      response.headers['access-control-allow-headers'],
      equals('Content-Type'),
    );
  });

  test('OPTIONS request handling', () async {
    final port = server.port;
    final client = HttpClient();
    try {
      final request = await client.openUrl(
        'OPTIONS',
        Uri.parse('http://localhost:$port/dpug/to-dart'),
      );
      final response = await request.close();

      expect(response.statusCode, equals(200));
      expect(response.headers['access-control-allow-origin'], [equals('*')]);
    } finally {
      client.close();
    }
  });
}
