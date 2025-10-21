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
      final args = <String>[];
      formatCommand.initializeArgs(args);
      try {
        await formatCommand.run();
        fail('Expected StateError');
      } catch (e) {
        expect(e, isA<StateError>());
      }
    });

    test('should show help', () async {
      final args = <String>['--help'];
      formatCommand.initializeArgs(args);
      try {
        await formatCommand.run();
        fail('Expected StateError');
      } catch (e) {
        expect(e, isA<StateError>());
      }
    });

    test('should handle non-existent files', () async {
      final args = ['nonexistent.dpug'];
      formatCommand.initializeArgs(args);
      try {
        await formatCommand.run();
        fail('Expected StateError');
      } catch (e) {
        expect(e, isA<StateError>());
      }
    });
  });
}
