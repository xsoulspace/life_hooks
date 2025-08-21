import 'dart:io';

import 'package:dpug_server/server.dart' as app;

Future<void> main(final List<String> args) async {
  final int port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final server = await app.serve(port: port);
  // print server address
  // ignore: avoid_print
  print('Serving on http://${server.address.host}:${server.port}');
}
