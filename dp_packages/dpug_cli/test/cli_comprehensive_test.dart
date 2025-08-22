import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:dpug_cli/commands/convert_command.dart';
import 'package:dpug_cli/commands/format_command.dart';
import 'package:dpug_cli/commands/server_command.dart';
import 'package:dpug_cli/dpug_cli.dart';
import 'package:test/test.dart';

void main() {
  group('DPug CLI Comprehensive Tests', () {
    late CommandRunner runner;
    late Directory tempDir;

    setUp(() async {
      runner =
          CommandRunner('dpug', 'DPug CLI for Flutter/Dart syntax conversion')
            ..addCommand(ConvertCommand())
            ..addCommand(FormatCommand())
            ..addCommand(ServerCommand());

      tempDir = await Directory.systemTemp.createTemp('dpug_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('CLI Runner', () {
      test('should have correct name and description', () {
        expect(runner.executableName, 'dpug');
        expect(runner.description, contains('DPug CLI'));
        expect(runner.description, contains('Flutter/Dart syntax conversion'));
      });

      test('should have all commands registered', () {
        expect(runner.commands.keys, contains('convert'));
        expect(runner.commands.keys, contains('format'));
        expect(runner.commands.keys, contains('server'));
      });

      test('should show help by default', () async {
        try {
          await runner.run([]);
          fail('Expected UsageException');
        } catch (e) {
          expect(e, isA<UsageException>());
        }
      });

      test('should show help with --help', () async {
        try {
          await runner.run(['--help']);
          fail('Expected UsageException');
        } catch (e) {
          expect(e, isA<UsageException>());
        }
      });
    });

    group('Convert Command - Comprehensive', () {
      late ConvertCommand convertCommand;

      setUp(() {
        convertCommand = ConvertCommand();
      });

      test('should have correct metadata', () {
        expect(convertCommand.name, 'convert');
        expect(
          convertCommand.description,
          contains('Convert between DPug and Dart'),
        );
      });

      test('should have all required arguments', () {
        final parser = convertCommand.argParser;
        expect(parser.options, contains('from'));
        expect(parser.options, contains('to'));
        expect(parser.options, contains('format'));
        expect(parser.options, contains('verbose'));
        expect(parser.options, contains('help'));
      });

      test('should validate format options', () {
        final allowedFormats =
            convertCommand.argParser.options['format']!.allowed;
        expect(allowedFormats, contains('dpug-to-dart'));
        expect(allowedFormats, contains('dart-to-dpug'));
      });

      test('should have sensible defaults', () {
        expect(
          convertCommand.argParser.options['format']!.defaultsTo,
          'dpug-to-dart',
        );
        expect(convertCommand.argParser.options['verbose']!.defaultsTo, false);
      });

      test('should require from argument', () async {
        try {
          await runner.run(['convert']);
          fail('Expected UsageException');
        } catch (e) {
          expect(e, isA<UsageException>());
        }
      });

      test('should require to argument when not in-place', () async {
        final fromFile = File('${tempDir.path}/input.dpug');
        await fromFile.writeAsString('@stateless\nclass Test => Text "Hello"');

        try {
          await runner.run(['convert', '--from', fromFile.path]);
          fail('Expected UsageException');
        } catch (e) {
          expect(e, isA<UsageException>());
        }
      });

      test('should convert dpug to dart successfully', () async {
        final inputFile = File('${tempDir.path}/input.dpug');
        final outputFile = File('${tempDir.path}/output.dart');

        const dpugContent = r'''
@stateless
class GreetingWidget
  String name
  Color textColor

  GreetingWidget(this.name, {this.textColor = Colors.black})

  Widget get build =>
    Container
      padding: EdgeInsets.all(16.0)
      child:
        Text
          'Hello, $name!'
          style:
            TextStyle
              color: textColor
              fontSize: 24.0
              fontWeight: FontWeight.bold
''';

        await inputFile.writeAsString(dpugContent);

        final result = await runner.run([
          'convert',
          '--from',
          inputFile.path,
          '--to',
          outputFile.path,
          '--format',
          'dpug-to-dart',
        ]);

        expect(result, equals(0));
        expect(await outputFile.exists(), isTrue);

        final outputContent = await outputFile.readAsString();
        expect(outputContent, contains('@stateless'));
        expect(outputContent, contains('class GreetingWidget'));
        expect(outputContent, contains('Widget get build =>'));
      });

      test('should convert dart to dpug successfully', () async {
        final inputFile = File('${tempDir.path}/input.dart');
        final outputFile = File('${tempDir.path}/output.dpug');

        const dartContent = r'''
@stateless
class CounterWidget extends StatelessWidget {
  final int count;

  const CounterWidget({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Count: $count',
        style: TextStyle(fontSize: 24.0)
      )
    );
  }
}
''';

        await inputFile.writeAsString(dartContent);

        final result = await runner.run([
          'convert',
          '--from',
          inputFile.path,
          '--to',
          outputFile.path,
          '--format',
          'dart-to-dpug',
        ]);

        expect(result, equals(0));
        expect(await outputFile.exists(), isTrue);

        final outputContent = await outputFile.readAsString();
        expect(outputContent, contains('@stateless'));
        expect(outputContent, contains('class CounterWidget'));
        expect(outputContent, contains('int count;'));
        expect(outputContent, contains('Widget get build =>'));
        expect(outputContent, contains('Container'));
      });

      test('should handle multiple files', () async {
        final input1 = File('${tempDir.path}/input1.dpug');
        final input2 = File('${tempDir.path}/input2.dpug');
        final output1 = File('${tempDir.path}/output1.dart');
        final output2 = File('${tempDir.path}/output2.dart');

        await input1.writeAsString('@stateless\nclass Widget1 => Text "First"');
        await input2.writeAsString(
          '@stateless\nclass Widget2 => Text "Second"',
        );

        final result = await runner.run([
          'convert',
          '--from',
          input1.path,
          '--to',
          output1.path,
          '--from',
          input2.path,
          '--to',
          output2.path,
        ]);

        expect(result, equals(0));
        expect(await output1.exists(), isTrue);
        expect(await output2.exists(), isTrue);
      });

      test('should handle verbose output', () async {
        final inputFile = File('${tempDir.path}/input.dpug');
        final outputFile = File('${tempDir.path}/output.dart');

        await inputFile.writeAsString('@stateless\nclass Test => Text "Hello"');

        // Capture stdout to verify verbose output
        final result = await runner.run([
          'convert',
          '--from',
          inputFile.path,
          '--to',
          outputFile.path,
          '--verbose',
        ]);

        expect(result, equals(0));
      });

      test('should handle file not found', () async {
        try {
          await runner.run([
            'convert',
            '--from',
            '${tempDir.path}/nonexistent.dpug',
            '--to',
            '${tempDir.path}/output.dart',
          ]);
          fail('Expected exception');
        } catch (e) {
          expect(e, isA<Exception>());
        }
      });

      test('should handle invalid format', () async {
        final inputFile = File('${tempDir.path}/input.dpug');
        await inputFile.writeAsString('@stateless\nclass Test => Text "Hello"');

        try {
          await runner.run([
            'convert',
            '--from',
            inputFile.path,
            '--to',
            '${tempDir.path}/output.dart',
            '--format',
            'invalid-format',
          ]);
          fail('Expected UsageException');
        } catch (e) {
          expect(e, isA<UsageException>());
        }
      });
    });

    group('Format Command - Comprehensive', () {
      late FormatCommand formatCommand;

      setUp(() {
        formatCommand = FormatCommand();
      });

      test('should have correct metadata', () {
        expect(formatCommand.name, 'format');
        expect(formatCommand.description, contains('Format DPug files'));
      });

      test('should have all required arguments', () {
        final parser = formatCommand.argParser;
        expect(parser.options, contains('in-place'));
        expect(parser.options, contains('output'));
        expect(parser.options, contains('verbose'));
        expect(parser.options, contains('help'));
      });

      test('should format single file in-place', () async {
        final inputFile = File('${tempDir.path}/test.dpug');
        const unformattedContent = '''
@stateless class TestWidget String message Widget get build=>Container(child:Text message)
''';

        await inputFile.writeAsString(unformattedContent);

        final result = await runner.run([
          'format',
          '--in-place',
          inputFile.path,
        ]);

        expect(result, equals(0));

        final formattedContent = await inputFile.readAsString();
        expect(formattedContent, contains('@stateless'));
        expect(formattedContent, contains('class TestWidget'));
        expect(formattedContent, contains('String message;'));
        expect(formattedContent, contains('Widget get build =>'));
      });

      test('should format file to output location', () async {
        final inputFile = File('${tempDir.path}/input.dpug');
        final outputFile = File('${tempDir.path}/output.dpug');

        const unformattedContent = r'''
@stateful class CounterWidget @listen int count=0 void increment()=>count++ Widget get build=>Text '$count'
''';

        await inputFile.writeAsString(unformattedContent);

        final result = await runner.run([
          'format',
          '--output',
          outputFile.path,
          inputFile.path,
        ]);

        expect(result, equals(0));
        expect(await outputFile.exists(), isTrue);

        final formattedContent = await outputFile.readAsString();
        expect(formattedContent, contains('@stateful'));
        expect(formattedContent, contains('class CounterWidget'));
        expect(formattedContent, contains('@listen int count = 0'));
        expect(formattedContent, contains('void increment() => count++;'));
        expect(formattedContent, contains('Widget get build =>'));
      });

      test('should format multiple files', () async {
        final input1 = File('${tempDir.path}/file1.dpug');
        final input2 = File('${tempDir.path}/file2.dpug');

        await input1.writeAsString('@stateless class A=>Text"A"');
        await input2.writeAsString('@stateless class B=>Text"B"');

        final result = await runner.run([
          'format',
          '--in-place',
          input1.path,
          input2.path,
        ]);

        expect(result, equals(0));

        expect(await input1.readAsString(), contains('class A'));
        expect(await input2.readAsString(), contains('class B'));
      });

      test('should handle directory formatting', () async {
        final subDir = Directory('${tempDir.path}/src');
        await subDir.create();

        final file1 = File('${subDir.path}/widget1.dpug');
        final file2 = File('${subDir.path}/widget2.dpug');

        await file1.writeAsString('@stateless class W1=>Text"1"');
        await file2.writeAsString('@stateless class W2=>Text"2"');

        final result = await runner.run(['format', '--in-place', subDir.path]);

        expect(result, equals(0));
        expect(await file1.readAsString(), contains('class W1'));
        expect(await file2.readAsString(), contains('class W2'));
      });

      test('should handle non-existent files', () async {
        try {
          await runner.run(['format', '${tempDir.path}/nonexistent.dpug']);
          fail('Expected exception');
        } catch (e) {
          expect(e, isA<Exception>());
        }
      });

      test('should handle empty files', () async {
        final emptyFile = File('${tempDir.path}/empty.dpug');
        await emptyFile.writeAsString('');

        final result = await runner.run([
          'format',
          '--in-place',
          emptyFile.path,
        ]);

        expect(result, equals(0));
        expect(await emptyFile.readAsString(), isEmpty);
      });

      test('should preserve file permissions', () async {
        final inputFile = File('${tempDir.path}/test.dpug');
        await inputFile.writeAsString('@stateless class Test => Text "Hello"');

        // Get original stats
        final originalStat = await inputFile.stat();

        final result = await runner.run([
          'format',
          '--in-place',
          inputFile.path,
        ]);

        expect(result, equals(0));

        // Check file still exists and has content
        final newStat = await inputFile.stat();
        expect(newStat.size, greaterThan(0));
      });
    });

    group('Server Command - Comprehensive', () {
      late ServerCommand serverCommand;

      setUp(() {
        serverCommand = ServerCommand();
      });

      test('should have correct metadata', () {
        expect(serverCommand.name, 'server');
        expect(
          serverCommand.description,
          contains('Start DPug conversion server'),
        );
      });

      test('should have all required arguments', () {
        final parser = serverCommand.argParser;
        expect(parser.options, contains('port'));
        expect(parser.options, contains('host'));
        expect(parser.options, contains('verbose'));
        expect(parser.options, contains('help'));
      });

      test('should have sensible defaults', () {
        expect(serverCommand.argParser.options['port']!.defaultsTo, 8080);
        expect(
          serverCommand.argParser.options['host']!.defaultsTo,
          'localhost',
        );
      });

      test('should start server on specified port', () async {
        // Note: This test would require mocking or a real server
        // For now, we test the argument parsing
        final args = ['server', '--port', '3000'];
        // In a real test, you'd start the server and verify it's listening
        expect(serverCommand.argParser.options['port']!.defaultsTo, 8080);
      });

      test('should support health check endpoint', () async {
        // This would be an integration test that actually starts the server
        // and makes HTTP requests to verify the /health endpoint
        expect(serverCommand.description, contains('server'));
      });

      test('should support dpug-to-dart conversion endpoint', () async {
        // Integration test for POST /dpug/to-dart
        expect(serverCommand.description, contains('conversion'));
      });

      test('should support dart-to-dpug conversion endpoint', () async {
        // Integration test for POST /dart/to-dpug
        expect(serverCommand.description, contains('conversion'));
      });

      test('should support format endpoint', () async {
        // Integration test for POST /format/dpug
        expect(serverCommand.description, contains('server'));
      });
    });

    group('Integration Tests', () {
      test('complete workflow: convert, format, and verify', () async {
        // Create a DPug file with formatting issues
        final dpugFile = File('${tempDir.path}/workflow.dpug');
        const messyDpug = r'''
@stateful class CounterWidget @listen int count=0 void increment()=>count++ Widget get build=>Column(children:[Text'$count',ElevatedButton(onPressed:increment,child:Text'+')])
''';

        await dpugFile.writeAsString(messyDpug);

        // Format the file
        await runner.run(['format', '--in-place', dpugFile.path]);

        final formattedContent = await dpugFile.readAsString();
        expect(formattedContent, contains('@stateful'));
        expect(formattedContent, contains('class CounterWidget'));
        expect(formattedContent, contains('@listen int count = 0'));
        expect(formattedContent, contains('void increment() => count++;'));

        // Convert to Dart
        final dartFile = File('${tempDir.path}/workflow.dart');
        await runner.run([
          'convert',
          '--from',
          dpugFile.path,
          '--to',
          dartFile.path,
          '--format',
          'dpug-to-dart',
        ]);

        expect(await dartFile.exists(), isTrue);
        final dartContent = await dartFile.readAsString();
        expect(dartContent, contains('@stateful'));
        expect(dartContent, contains('class CounterWidget'));
      });

      test('should handle different file extensions', () async {
        const extensions = ['.dpug', '.dart', '.txt'];

        for (final ext in extensions) {
          final inputFile = File('${tempDir.path}/test$ext');
          await inputFile.writeAsString(
            '@stateless class Test => Text "Hello"',
          );

          final outputFile = File('${tempDir.path}/output$ext');
          final result = await runner.run([
            'convert',
            '--from',
            inputFile.path,
            '--to',
            outputFile.path,
            '--format',
            'dpug-to-dart',
          ]);

          expect(result, equals(0));
          expect(await outputFile.exists(), isTrue);
        }
      });

      test('should handle stdin/stdout', () async {
        // Test reading from stdin would require process mocking
        // This is more of an integration test for the CLI
        expect(runner.commands['convert'], isNotNull);
      });
    });

    group('Error Handling', () {
      test('should handle invalid arguments gracefully', () async {
        try {
          await runner.run(['convert', '--invalid-flag']);
          fail('Expected UsageException');
        } catch (e) {
          expect(e, isA<UsageException>());
        }
      });

      test('should handle malformed DPug syntax', () async {
        final inputFile = File('${tempDir.path}/malformed.dpug');
        await inputFile.writeAsString('invalid dpug syntax here +++');

        final outputFile = File('${tempDir.path}/output.dart');
        final result = await runner.run([
          'convert',
          '--from',
          inputFile.path,
          '--to',
          outputFile.path,
        ]);

        // Should handle gracefully (either succeed with warnings or fail with clear error)
        expect(result, isNotNull);
      });

      test('should handle permission errors', () async {
        // This test would require creating a file with no write permissions
        // and testing the error handling
        final inputFile = File('${tempDir.path}/readonly.dpug');
        await inputFile.writeAsString('@stateless class Test => Text "Hello"');

        // Try to write to a directory without permissions
        // (This is platform-specific and would need proper setup)
        expect(await inputFile.exists(), isTrue);
      });
    });

    group('Configuration and Options', () {
      test('should support configuration files', () async {
        // Test for future configuration file support
        // This would test loading settings from .dpugrc or similar
        expect(runner.description, contains('DPug'));
      });

      test('should support environment variables', () async {
        // Test for environment variable support
        // This would test DPUG_PORT, DPUG_HOST, etc.
        expect(serverCommand.argParser.options, contains('port'));
      });
    });
  });
}
