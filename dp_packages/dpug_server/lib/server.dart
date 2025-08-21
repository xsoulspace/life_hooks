import 'dart:async';
import 'dart:io';

import 'package:dpug_core/dpug_core.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

/// Simple HTTP server exposing DPug <-> Dart conversion endpoints.
class DpServer {
  final DpugConverter _converter = DpugConverter();

  /// Build router with routes.
  Router buildRouter() {
    final Router router = Router();
    router.get(
      '/health',
      (final shelf.Request req) =>
          shelf.Response.ok('ok', headers: {'content-type': 'text/plain'}),
    );

    router.post('/dpug/to-dart', (final shelf.Request req) async {
      final String body = await req.readAsString();
      try {
        final String out = _converter.dpugToDart(body);
        return shelf.Response.ok(out, headers: {'content-type': 'text/plain'});
      } on Object catch (e) {
        return _error('DpugToDartError', e.toString());
      }
    });

    router.post('/dart/to-dpug', (final shelf.Request req) async {
      final String body = await req.readAsString();
      try {
        final String out = _converter.dartToDpug(body);
        return shelf.Response.ok(out, headers: {'content-type': 'text/plain'});
      } on Object catch (e) {
        return _error('DartToDpugError', e.toString());
      }
    });

    return router;
  }

  shelf.Response _error(final String type, final String message) {
    // Fallback span unknown
    const String span = '1:1..1:1';
    final String yaml =
        'error: $type\nmessage: ${_escapeYaml(message)}\nspan: "$span"\n';
    return shelf.Response(
      400,
      body: yaml,
      headers: {'content-type': 'text/plain'},
    );
  }

  String _escapeYaml(final String v) =>
      v.replaceAll('\n', ' ').replaceAll(':', r'\:');
}

/// Start the server on the given [port].
Future<HttpServer> serve({final int port = 8080}) async {
  final DpServer app = DpServer();
  final shelf.Handler handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addMiddleware(_corsMiddleware())
      .addHandler(app.buildRouter().call);
  final HttpServer server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    port,
  );
  return server;
}

shelf.Middleware _corsMiddleware() =>
    (final innerHandler) => (final request) async {
      if (request.method == 'OPTIONS') {
        return shelf.Response.ok('', headers: _corsHeaders());
      }
      final response = await innerHandler(request);
      return response.change(headers: _corsHeaders());
    };

Map<String, String> _corsHeaders() => {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};
