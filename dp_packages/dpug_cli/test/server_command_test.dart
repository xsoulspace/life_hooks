import 'package:args/command_runner.dart';
import 'package:dpug_cli/commands/server_command.dart';
import 'package:test/test.dart';

void main() {
  group('ServerCommand', () {
    late CommandRunner runner;
    late ServerCommand serverCommand;

    setUp(() {
      serverCommand = ServerCommand();
      runner = CommandRunner('dpug', 'Test runner')..addCommand(serverCommand);
    });

    test('should have correct name and description', () {
      expect(serverCommand.name, 'server');
      expect(
        serverCommand.description,
        contains('Start or manage the DPug HTTP server'),
      );
    });

    test('should have subcommands', () {
      expect(serverCommand.subcommands, contains('start'));
      expect(serverCommand.subcommands, contains('health'));
    });
  });

  group('ServerStartCommand', () {
    late ServerStartCommand startCommand;

    setUp(() {
      startCommand = ServerStartCommand();
    });

    test('should have correct name and description', () {
      expect(startCommand.name, 'start');
      expect(startCommand.description, contains('Start the DPug HTTP server'));
    });

    test('should have required arguments', () {
      expect(startCommand.argParser.options, contains('port'));
      expect(startCommand.argParser.options, contains('host'));
      expect(startCommand.argParser.options, contains('verbose'));
    });

    test('should have sensible defaults', () {
      expect(startCommand.argParser.options['port']!.defaultsTo, '8080');
      expect(startCommand.argParser.options['host']!.defaultsTo, 'localhost');
    });
  });

  group('ServerHealthCommand', () {
    late ServerHealthCommand healthCommand;

    setUp(() {
      healthCommand = ServerHealthCommand();
    });

    test('should have correct name and description', () {
      expect(healthCommand.name, 'health');
      expect(healthCommand.description, contains('Check server health'));
    });

    test('should have required arguments', () {
      expect(healthCommand.argParser.options, contains('port'));
      expect(healthCommand.argParser.options, contains('host'));
    });

    test('should have sensible defaults', () {
      expect(healthCommand.argParser.options['port']!.defaultsTo, '8080');
      expect(healthCommand.argParser.options['host']!.defaultsTo, 'localhost');
    });
  });
}
