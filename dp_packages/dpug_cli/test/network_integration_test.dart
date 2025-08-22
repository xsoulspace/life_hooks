import 'dart:convert';
import 'dart:io';

import 'package:dpug_cli/commands/server_command.dart';
import 'package:test/test.dart';

void main() {
  group('Network Integration Tests', () {
    late ServerCommand serverCommand;
    const baseUrl = 'http://localhost:8999';

    setUp(() {
      serverCommand = ServerCommand();
    });

    tearDown(() async {
      // Clean up any running servers
      try {
        final response = await _makeHttpRequest('$baseUrl/health');
        if (response == 'ok') {
          // Server is running, try to stop it
          await Process.run('pkill', ['-f', 'dpug.*server']);
          await Future.delayed(Duration(seconds: 1));
        }
      } catch (e) {
        // Server not running or couldn't be stopped
      }
    });

    group('HTTP Server Startup and Health', () {
      test('Server starts successfully on specified port', () async {
        const port = 8999;
        final serverProcess = await serverCommand.runCommand(port: port);
        expect(serverProcess, isNotNull);

        // Wait for server to start
        await Future.delayed(Duration(seconds: 3));

        try {
          // Test health endpoint
          final healthResponse = await _makeHttpRequest('$baseUrl/health');
          expect(healthResponse, equals('ok'));

          // Verify server is responsive
          final healthStatus = await _getHttpStatus('$baseUrl/health');
          expect(healthStatus, equals(200));
        } finally {
          serverProcess.kill();
          await serverProcess.exitCode;
        }
      });

      test('Server handles different ports', () async {
        const ports = [8000, 8080, 9000];

        for (final port in ports) {
          final serverProcess = await serverCommand.runCommand(port: port);
          await Future.delayed(Duration(seconds: 2));

          try {
            final response = await _makeHttpRequest(
              'http://localhost:$port/health',
            );
            expect(response, equals('ok'));
          } finally {
            serverProcess.kill();
            await serverProcess.exitCode;
          }
        }
      });

      test('Server startup with invalid ports', () async {
        // Test with invalid port numbers
        const invalidPorts = [-1, 0, 65536, 100000];

        for (final port in invalidPorts) {
          expect(
            () => serverCommand.runCommand(port: port),
            throwsA(isA<ArgumentError>()),
          );
        }
      });

      test('Server graceful shutdown', () async {
        const port = 8999;
        final serverProcess = await serverCommand.runCommand(port: port);
        await Future.delayed(Duration(seconds: 2));

        // Verify server is running
        final healthResponse = await _makeHttpRequest('$baseUrl/health');
        expect(healthResponse, equals('ok'));

        // Kill the server process
        serverProcess.kill();
        final exitCode = await serverProcess.exitCode;

        expect(exitCode, isNotNull);

        // Verify server is no longer responding
        expect(
          () => _makeHttpRequest('$baseUrl/health'),
          throwsA(isA<SocketException>()),
        );
      });
    });

    group('DPug to Dart API Endpoint', () {
      late Process serverProcess;

      setUp(() async {
        serverProcess = await serverCommand.runCommand(port: 8999);
        await Future.delayed(Duration(seconds: 3)); // Wait for server to start
      });

      tearDown(() async {
        serverProcess.kill();
        await serverProcess.exitCode;
      });

      test('Basic DPug to Dart conversion', () async {
        const dpugPayload = '''
Text
  ..text: "Hello Network World"
  ..style:
    TextStyle
      ..fontSize: 18.0
      ..fontWeight: FontWeight.bold
''';

        final response = await _makeHttpPostRequest(
          '$baseUrl/dpug/to-dart',
          dpugPayload,
        );

        expect(response, contains('Text'));
        expect(response, contains('Hello Network World'));
        expect(response, contains('TextStyle'));
        expect(response, contains('fontSize: 18.0'));
        expect(response, contains('FontWeight.bold'));
        expect(response, contains('extends StatelessWidget'));
      });

      test('Complex widget conversion via API', () async {
        const complexDpug = '''
@stateful
class NetworkTestWidget
  @listen String message = "Network Test"

  Widget get build =>
    Scaffold
      ..appBar:
        AppBar
          ..title: "Network Test"
      ..body:
        Center
          ..child:
            Column
              mainAxisAlignment: MainAxisAlignment.center
              children:
                Text
                  ..text: message
                  ..style:
                    TextStyle
                      ..fontSize: 24.0
                ElevatedButton
                  ..onPressed: () => message = "Button Pressed"
                  ..child:
                    Text
                      ..text: "Press Me"
''';

        final response = await _makeHttpPostRequest(
          '$baseUrl/dpug/to-dart',
          complexDpug,
        );

        expect(response, contains('class NetworkTestWidget'));
        expect(response, contains('extends StatefulWidget'));
        expect(response, contains('Scaffold'));
        expect(response, contains('AppBar'));
        expect(response, contains('Center'));
        expect(response, contains('Column'));
        expect(response, contains('TextStyle'));
        expect(response, contains('ElevatedButton'));
      });

      test('API handles empty input', () async {
        const emptyPayload = '';

        final response = await _makeHttpPostRequest(
          '$baseUrl/dpug/to-dart',
          emptyPayload,
        );

        // Should return some valid Dart code or empty result
        expect(response, isNotNull);
      });

      test('API handles malformed DPug', () async {
        const malformedDpug = '''
@invalid
class Broken
  @unknown int value = "not_a_number"

  Widget get build =>
    UnknownWidget
      ..invalid_prop: "value"
''';

        final response = await _makeHttpPostRequest(
          '$baseUrl/dpug/to-dart',
          malformedDpug,
        );

        // Should return error response or handle gracefully
        expect(response, isNotNull);
        // The response might contain error information or partial conversion
      });

      test('API handles Unicode and special characters', () async {
        const unicodeDpug = '''
Text
  ..text: "Hello 🌍 世界! Ñoño 🚀"
  ..style:
    TextStyle
      ..fontSize: 16.0
      ..color: Color(0xFF42A5F5)
''';

        final response = await _makeHttpPostRequest(
          '$baseUrl/dpug/to-dart',
          unicodeDpug,
        );

        expect(response, contains('Hello 🌍 世界! Ñoño 🚀'));
        expect(response, contains('Color(0xFF42A5F5)'));
        expect(response, contains('TextStyle'));
      });

      test('API handles large payloads', () async {
        // Create a large DPug payload
        final largeDpug = StringBuffer();
        largeDpug.writeln('@stateful');
        largeDpug.writeln('class LargeNetworkWidget');
        largeDpug.writeln('  @listen int counter = 0');
        largeDpug.writeln('');
        largeDpug.writeln('  Widget get build =>');
        largeDpug.writeln('    Column');
        largeDpug.writeln('      children:');

        for (int i = 0; i < 500; i++) {
          largeDpug.writeln('      Text');
          largeDpug.writeln('        ..text: "Network Item $i"');
        }

        final response = await _makeHttpPostRequest(
          '$baseUrl/dpug/to-dart',
          largeDpug.toString(),
        );

        expect(response, contains('class LargeNetworkWidget'));
        expect(response, contains('extends StatefulWidget'));
        expect(response, contains('Network Item 0'));
        expect(response, contains('Network Item 499'));
      });
    });

    group('Dart to DPug API Endpoint', () {
      late Process serverProcess;

      setUp(() async {
        serverProcess = await serverCommand.runCommand(port: 8999);
        await Future.delayed(Duration(seconds: 3));
      });

      tearDown(() async {
        serverProcess.kill();
        await serverProcess.exitCode;
      });

      test('Basic Dart to DPug conversion', () async {
        const dartPayload = '''
class TestWidget extends StatelessWidget {
  final String message;

  const TestWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
''';

        final response = await _makeHttpPostRequest(
          '$baseUrl/dart/to-dpug',
          dartPayload,
        );

        expect(response, contains('class TestWidget'));
        expect(response, contains('@stateless'));
        expect(response, contains('Text'));
        expect(response, contains('TextStyle'));
        expect(response, contains('fontSize: 18.0'));
        expect(response, contains('FontWeight.bold'));
      });

      test('Complex Dart to DPug conversion', () async {
        const dartPayload = '''
class ComplexWidget extends StatefulWidget {
  @override
  _ComplexWidgetState createState() => _ComplexWidgetState();
}

class _ComplexWidgetState extends State<ComplexWidget> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complex Widget'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Counter: \$counter'),
            ElevatedButton(
              onPressed: () => setState(() => counter++),
              child: Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}
''';

        final response = await _makeHttpPostRequest(
          '$baseUrl/dart/to-dpug',
          dartPayload,
        );

        expect(response, contains('class ComplexWidget'));
        expect(response, contains('@stateful'));
        expect(response, contains('@listen int counter = 0'));
        expect(response, contains('Scaffold'));
        expect(response, contains('AppBar'));
        expect(response, contains('Center'));
        expect(response, contains('Column'));
        expect(response, contains('ElevatedButton'));
      });
    });

    group('Format API Endpoint', () {
      late Process serverProcess;

      setUp(() async {
        serverProcess = await serverCommand.runCommand(port: 8999);
        await Future.delayed(Duration(seconds: 3));
      });

      tearDown(() async {
        serverProcess.kill();
        await serverProcess.exitCode;
      });

      test('Format DPug via API', () async {
        const messyDpug = '''
@stateful    class    MessyWidget
      @listen    int    value=0

 Widget   get   build   =>
     Text
       ..text:    "Messy Text"
''';

        final response = await _makeHttpPostRequest(
          '$baseUrl/format/dpug',
          messyDpug,
        );

        expect(response, contains('class MessyWidget'));
        expect(response, contains('@listen int value = 0'));
        expect(response, contains('Widget get build =>'));
        expect(response, contains('Text'));
        expect(response, contains('Messy Text'));

        // Should have proper indentation
        final lines = response.split('\n');
        final classLine = lines.firstWhere((line) => line.contains('class'));
        expect(classLine, startsWith('@stateful')); // No extra indentation
      });

      test('Format with different indentation styles', () async {
        const dpugToFormat = '''
Text
..text: "Test"
''';

        final response = await _makeHttpPostRequest(
          '$baseUrl/format/dpug',
          dpugToFormat,
        );

        expect(response, contains('Text'));
        expect(response, contains('text: "Test"'));

        // Should be properly indented
        final lines = response.split('\n');
        expect(lines[0], equals('Text'));
        expect(lines[1], startsWith('  ..text:'));
      });
    });

    group('Concurrent Requests and Performance', () {
      late Process serverProcess;

      setUp(() async {
        serverProcess = await serverCommand.runCommand(port: 8999);
        await Future.delayed(Duration(seconds: 3));
      });

      tearDown(() async {
        serverProcess.kill();
        await serverProcess.exitCode;
      });

      test('Handle multiple concurrent requests', () async {
        const requestCount = 20;
        const dpugPayload = 'Text\n  ..text: "Concurrent Test"';

        final futures = List.generate(requestCount, (i) async {
          return await _makeHttpPostRequest(
            '$baseUrl/dpug/to-dart',
            '$dpugPayload $i',
          );
        });

        final responses = await Future.wait(futures);

        expect(responses.length, equals(requestCount));

        for (int i = 0; i < requestCount; i++) {
          expect(responses[i], contains('Text'));
          expect(responses[i], contains('Concurrent Test $i'));
          expect(responses[i], contains('extends StatelessWidget'));
        }
      });

      test('Performance with large concurrent payloads', () async {
        const concurrentCount = 10;

        final futures = List.generate(concurrentCount, (i) async {
          final largeDpug = StringBuffer();
          largeDpug.writeln('@stateful');
          largeDpug.writeln('class ConcurrentWidget$i');
          largeDpug.writeln('  @listen int value$i = $i');
          largeDpug.writeln('');
          largeDpug.writeln('  Widget get build =>');
          largeDpug.writeln('    Column');
          largeDpug.writeln('      children:');

          for (int j = 0; j < 100; j++) {
            largeDpug.writeln('      Text');
            largeDpug.writeln('        ..text: "Item $i-$j"');
          }

          return await _makeHttpPostRequest(
            '$baseUrl/dpug/to-dart',
            largeDpug.toString(),
          );
        });

        final startTime = DateTime.now();
        final responses = await Future.wait(futures);
        final endTime = DateTime.now();

        final duration = endTime.difference(startTime);
        expect(
          duration.inSeconds,
          lessThan(30),
        ); // Should complete within 30 seconds

        expect(responses.length, equals(concurrentCount));

        for (int i = 0; i < concurrentCount; i++) {
          expect(responses[i], contains('class ConcurrentWidget$i'));
          expect(responses[i], contains('extends StatefulWidget'));
          expect(responses[i], contains('value$i = $i'));
          expect(responses[i], contains('Item $i-0'));
          expect(responses[i], contains('Item $i-99'));
        }
      });

      test('Server stability under load', () async {
        const requestCount = 50;

        final futures = List.generate(requestCount, (i) async {
          const dpugPayload =
              '''
@stateless
class LoadTest$i
  Widget get build =>
    Text
      ..text: "Load Test $i"
''';

          return await _makeHttpPostRequest(
            '$baseUrl/dpug/to-dart',
            dpugPayload,
          );
        });

        final responses = await Future.wait(futures);

        // All requests should succeed
        for (int i = 0; i < requestCount; i++) {
          expect(responses[i], contains('class LoadTest$i'));
          expect(responses[i], contains('Load Test $i'));
        }

        // Server should still be healthy after load
        final healthResponse = await _makeHttpRequest('$baseUrl/health');
        expect(healthResponse, equals('ok'));
      });
    });

    group('Error Handling and Edge Cases', () {
      late Process serverProcess;

      setUp(() async {
        serverProcess = await serverCommand.runCommand(port: 8999);
        await Future.delayed(Duration(seconds: 3));
      });

      tearDown(() async {
        serverProcess.kill();
        await serverProcess.exitCode;
      });

      test('Handle invalid HTTP methods', () async {
        final client = HttpClient();

        try {
          final request = await client.putUrl(Uri.parse('$baseUrl/health'));
          final response = await request.close();
          final statusCode = response.statusCode;

          // Should return method not allowed or similar error
          expect(statusCode, isNot(equals(200)));
        } finally {
          client.close();
        }
      });

      test('Handle malformed JSON payloads', () async {
        final client = HttpClient();

        try {
          final request = await client.postUrl(
            Uri.parse('$baseUrl/dpug/to-dart'),
          );
          request.headers.contentType = ContentType.json;
          request.write('{ invalid json }');
          final response = await request.close();
          final statusCode = response.statusCode;

          // Should handle malformed input gracefully
          expect(
            statusCode,
            isNot(equals(500)),
          ); // Should not be internal server error
        } finally {
          client.close();
        }
      });

      test('Handle extremely large payloads', () async {
        // Create an extremely large payload (multiple MB)
        final largePayload = 'Text\n  ..text: "' + 'X' * 1000000 + '"\n';

        final response = await _makeHttpPostRequest(
          '$baseUrl/dpug/to-dart',
          largePayload,
        );

        // Should handle large payloads gracefully
        expect(response, isNotNull);
        expect(response, contains('Text'));
      });

      test('Handle rapid successive requests', () async {
        const requestCount = 100;
        const dpugPayload = 'Text\n  ..text: "Rapid Test"';

        final responses = <String>[];

        for (int i = 0; i < requestCount; i++) {
          final response = await _makeHttpPostRequest(
            '$baseUrl/dpug/to-dart',
            dpugPayload,
          );
          responses.add(response);
        }

        expect(responses.length, equals(requestCount));

        for (final response in responses) {
          expect(response, contains('Text'));
          expect(response, contains('Rapid Test'));
        }
      });

      test('Handle server restart scenarios', () async {
        // Verify server is running
        final initialHealth = await _makeHttpRequest('$baseUrl/health');
        expect(initialHealth, equals('ok'));

        // Kill and restart server
        serverProcess.kill();
        await serverProcess.exitCode;

        // Start new server instance
        final newServerProcess = await serverCommand.runCommand(port: 8999);
        await Future.delayed(Duration(seconds: 3));

        try {
          // Test new server instance
          final newHealth = await _makeHttpRequest('$baseUrl/health');
          expect(newHealth, equals('ok'));

          const testPayload = 'Text\n  ..text: "Restart Test"';
          final response = await _makeHttpPostRequest(
            '$baseUrl/dpug/to-dart',
            testPayload,
          );

          expect(response, contains('Restart Test'));
        } finally {
          newServerProcess.kill();
          await newServerProcess.exitCode;
        }
      });
    });

    group('HTTP Headers and Content Types', () {
      late Process serverProcess;

      setUp(() async {
        serverProcess = await serverCommand.runCommand(port: 8999);
        await Future.delayed(Duration(seconds: 3));
      });

      tearDown(() async {
        serverProcess.kill();
        await serverProcess.exitCode;
      });

      test('Proper content type handling', () async {
        final client = HttpClient();

        try {
          const dpugPayload = 'Text\n  ..text: "Content Type Test"';

          final request = await client.postUrl(
            Uri.parse('$baseUrl/dpug/to-dart'),
          );
          request.headers.contentType = ContentType.text;
          request.write(dpugPayload);

          final response = await request.close();
          final responseBody = await response.transform(utf8.decoder).join();

          expect(response.statusCode, equals(200));
          expect(responseBody, contains('Content Type Test'));
        } finally {
          client.close();
        }
      });

      test('Handle different content types gracefully', () async {
        final client = HttpClient();
        const testPayload = 'Test Content';

        final contentTypes = [
          ContentType.text,
          ContentType.json,
          ContentType.html,
        ];

        for (final contentType in contentTypes) {
          try {
            final request = await client.postUrl(
              Uri.parse('$baseUrl/dpug/to-dart'),
            );
            request.headers.contentType = contentType;
            request.write(testPayload);

            final response = await request.close();
            final statusCode = response.statusCode;

            // Should handle different content types
            expect(statusCode, isNot(equals(500))); // Not internal server error
          } catch (e) {
            // Some content types might cause issues, but shouldn't crash server
            expect(e, isNot(isA<Exception>()));
          }
        }

        client.close();
      });

      test('Response headers are appropriate', () async {
        final client = HttpClient();

        try {
          const dpugPayload = 'Text\n  ..text: "Headers Test"';

          final request = await client.postUrl(
            Uri.parse('$baseUrl/dpug/to-dart'),
          );
          request.headers.contentType = ContentType.text;
          request.write(dpugPayload);

          final response = await request.close();

          expect(response.statusCode, equals(200));
          expect(response.headers.contentType, isNotNull);

          // Should have appropriate content type for response
          final contentType = response.headers.contentType.toString();
          expect(contentType, contains('text') | contains('application'));

          final responseBody = await response.transform(utf8.decoder).join();
          expect(responseBody, contains('Headers Test'));
        } finally {
          client.close();
        }
      });
    });
  });
}

// Helper functions for HTTP requests
Future<String> _makeHttpRequest(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    return await response.transform(utf8.decoder).join();
  } finally {
    client.close();
  }
}

Future<String> _makeHttpPostRequest(String url, String body) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse(url));
    request.headers.contentType = ContentType.text;
    request.write(body);
    final response = await request.close();
    return await response.transform(utf8.decoder).join();
  } finally {
    client.close();
  }
}

Future<int> _getHttpStatus(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    return response.statusCode;
  } finally {
    client.close();
  }
}
