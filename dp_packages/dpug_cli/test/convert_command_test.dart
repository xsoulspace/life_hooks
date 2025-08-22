import 'package:args/command_runner.dart';
import 'package:dpug_cli/commands/convert_command.dart';
import 'package:test/test.dart';

void main() {
  group('ConvertCommand', () {
    late CommandRunner runner;
    late ConvertCommand convertCommand;

    setUp(() {
      convertCommand = ConvertCommand();
      runner = CommandRunner('dpug', 'Test runner')..addCommand(convertCommand);
    });

    test('should have correct name and description', () {
      expect(convertCommand.name, 'convert');
      expect(
        convertCommand.description,
        contains('Convert between DPug and Dart'),
      );
    });

    test('should have required arguments', () {
      expect(convertCommand.argParser.options, contains('from'));
      expect(convertCommand.argParser.options, contains('to'));
      expect(convertCommand.argParser.options, contains('format'));
      expect(convertCommand.argParser.options, contains('verbose'));
    });

    test('should require from argument', () async {
      final args = ['convert'];
      try {
        await runner.run(args);
        fail('Expected UsageException');
      } catch (e) {
        expect(e, isA<UsageException>());
      }
    });

    test('should show help', () async {
      final args = ['convert', '--help'];
      try {
        await runner.run(args);
        fail('Expected UsageException');
      } catch (e) {
        expect(e, isA<UsageException>());
      }
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
    });
  });
}
