import 'package:args/command_runner.dart';
import 'package:dpug_cli/commands/format_command.dart';
import 'package:test/test.dart';

void main() {
  group('FormatCommand', () {
    late CommandRunner runner;
    late FormatCommand formatCommand;

    setUp(() {
      formatCommand = FormatCommand();
      runner = CommandRunner('dpug', 'Test runner')..addCommand(formatCommand);
    });

    test('should have correct name and description', () {
      expect(formatCommand.name, 'format');
      expect(formatCommand.description, contains('Format DPug files'));
    });

    test('should have required arguments', () {
      expect(formatCommand.argParser.options, contains('in-place'));
      expect(formatCommand.argParser.options, contains('output'));
      expect(formatCommand.argParser.options, contains('verbose'));
    });

    test('should handle missing files gracefully', () async {
      final args = ['format'];
      try {
        await runner.run(args);
        fail('Expected UsageException');
      } catch (e) {
        expect(e, isA<UsageException>());
      }
    });

    test('should show help', () async {
      final args = ['format', '--help'];
      try {
        await runner.run(args);
        fail('Expected UsageException');
      } catch (e) {
        expect(e, isA<UsageException>());
      }
    });

    test('should handle non-existent files', () async {
      final args = ['format', 'nonexistent.dpug'];
      // This would normally exit with code 1, but in tests we catch it
      try {
        await runner.run(args);
        fail('Expected exception');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });
}
