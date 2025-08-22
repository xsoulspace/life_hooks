import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dpug_server/server.dart' as dpug_server;
import 'package:http/http.dart' as http;

import '../dpug_cli.dart';

/// Server management command
class ServerCommand extends Command {
  ServerCommand() {
    addSubcommand(ServerStartCommand());
    addSubcommand(ServerHealthCommand());
  }
  @override
  String get name => 'server';

  @override
  String get description => 'Start or manage the DPug HTTP server';

  @override
  String get invocation => 'dpug server <command> [options]';

  @override
  Future<void> run() async {
    // This command requires a subcommand
    print('Use "dpug server start" or "dpug server health"');
  }
}

/// Start server subcommand
class ServerStartCommand extends Command {
  ServerStartCommand() {
    argParser
      ..addOption(
        'port',
        abbr: 'p',
        help: 'Port to bind to',
        defaultsTo: '8080',
      )
      ..addOption('host', help: 'Host to bind to', defaultsTo: 'localhost')
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Show detailed output',
        negatable: false,
      );
  }
  @override
  String get name => 'start';

  @override
  String get description => 'Start the DPug HTTP server';

  @override
  String get invocation => 'dpug server start [options]';

  @override
  Future<void> run() async {
    final args = argResults;
    if (args == null) return;

    final port = int.tryParse(args['port'] as String) ?? 8080;
    final host = args['host'] as String;
    final verbose = args['verbose'] as bool;

    try {
      if (verbose) {
        DpugCliUtils.printInfo('Starting DPug server on http://$host:$port');
      }

      // Start the dpug_server
      try {
        final server = await dpug_server.serve(port: port);
        DpugCliUtils.printSuccess(
          'Server started on http://${server.address.host}:${server.port}',
        );

        // Keep the server running - in CLI context this would block
        // For now, just return after starting
      } catch (e) {
        throw Exception('Server start failed: $e');
      }
    } catch (e) {
      DpugCliUtils.printError('Failed to start server: $e');
      exit(1);
    }
  }
}

/// Health check subcommand
class ServerHealthCommand extends Command {
  ServerHealthCommand() {
    argParser
      ..addOption('port', abbr: 'p', help: 'Server port', defaultsTo: '8080')
      ..addOption('host', help: 'Server host', defaultsTo: 'localhost');
  }
  @override
  String get name => 'health';

  @override
  String get description => 'Check server health';

  @override
  String get invocation => 'dpug server health [options]';

  @override
  Future<void> run() async {
    final args = argResults;
    if (args == null) return;

    final port = int.tryParse(args['port'] as String) ?? 8080;
    final host = args['host'] as String;

    try {
      DpugCliUtils.printInfo(
        'Checking server health at http://$host:$port/health',
      );

      final response = await http.get(Uri.parse('http://$host:$port/health'));

      if (response.statusCode == 200) {
        DpugCliUtils.printSuccess('Server is healthy');
      } else {
        throw Exception('Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      DpugCliUtils.printError('Server health check failed: $e');
      exit(1);
    }
  }
}
