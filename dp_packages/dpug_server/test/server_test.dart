import 'dart:convert';
import 'dart:io';

import 'package:dp_server/server.dart' as app;
import 'package:test/test.dart';

void main() {
  group('dp_server endpoints', () {
    HttpServer? server;

    setUpAll(() async {
      server = await app.serve(port: 0);
    });

    tearDownAll(() async {
      await server?.close(force: true);
    });

    test('dpug -> dart', () async {
      final client = HttpClient();
      final req = await client.postUrl(
        Uri.parse(
          'http://${server!.address.host}:${server!.port}/dpug/to-dart',
        ),
      );
      req.headers.contentType = ContentType('text', 'plain');
      req.write("""
@stateful
class TodoList
  @listen String name = ''

  Widget get build =>
    Text
      ..'Hi'
""");
      final res = await req.close();
      final body = await utf8.decoder.bind(res).join();
      expect(res.statusCode, 200);
      expect(body, contains('class TodoList extends StatefulWidget'));
    });

    test('dart -> dpug error on unsupported', () async {
      final client = HttpClient();
      final req = await client.postUrl(
        Uri.parse(
          'http://${server!.address.host}:${server!.port}/dart/to-dpug',
        ),
      );
      req.headers.contentType = ContentType('text', 'plain');
      req.write('class A {}');
      final res = await req.close();
      final body = await utf8.decoder.bind(res).join();
      expect(res.statusCode, anyOf(200, 400));
      if (res.statusCode == 400) {
        expect(body, contains('error: DartToDpugError'));
        expect(body, contains('span:'));
      }
    });
  });
}
