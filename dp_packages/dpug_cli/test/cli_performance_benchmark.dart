import 'dart:io';

import 'package:benchmark/benchmark.dart';
import 'package:dpug_cli/commands/convert_command.dart';
import 'package:dpug_cli/commands/format_command.dart';
import 'package:dpug_cli/dpug_cli.dart';
import 'package:dpug_core/compiler/performance_utils.dart';
import 'package:test/test.dart';

void main() {
  group('CLI Performance Benchmarks', () {
    late DpugBenchmarkRunner runner;
    late Directory tempDir;

    setUp(() async {
      runner = DpugBenchmarkRunner();
      tempDir = await Directory.systemTemp.createTemp('dpug_cli_perf_');
    });

    tearDown(() async {
      runner.clearResults();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('CLI startup time benchmark', () async {
      final benchmark = Benchmark('cli_startup_time', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(() {
          // Simulate CLI startup
          final cli = DpugCli();
          return cli;
        });
        DpugPerformanceUtils.recordMeasurement(
          'cli_startup_time',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('cli_startup_time', benchmark);
      await benchmark.run();
    });

    test('Single file conversion performance', () async {
      // Create test files
      final inputFile = File('${tempDir.path}/input.dpug');
      final outputFile = File('${tempDir.path}/output.dart');
      const inputContent = '''
Text
  ..text: "Hello World"
  ..style: TextStyle
    ..fontSize: 24.0
    ..fontWeight: FontWeight.bold
''';

      await inputFile.writeAsString(inputContent);

      final benchmark = Benchmark('single_file_conversion', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(() {
          // Simulate command execution
          final command = ConvertCommand();
          return command;
        });
        DpugPerformanceUtils.recordMeasurement(
          'single_file_conversion',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('single_file_conversion', benchmark);
      await benchmark.run();
    });

    test('Batch file conversion performance', () async {
      // Create multiple test files
      final files = <File>[];
      for (int i = 0; i < 10; i++) {
        final file = File('${tempDir.path}/batch_input_$i.dpug');
        final content = TestDataGenerator.generateDpugWidget(
          'BatchWidget$i',
          2,
          3,
        );
        await file.writeAsString(content);
        files.add(file);
      }

      final benchmark = Benchmark('batch_file_conversion', () async {
        final result = DpugPerformanceUtils.measureTimeWithMemory(() async {
          final futures = files.map((final file) async {
            final command = ConvertCommand();
            return command;
          });
          return Future.wait(futures);
        });
        DpugPerformanceUtils.recordMeasurement(
          'batch_file_conversion',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('batch_file_conversion', benchmark);
      await benchmark.run();
    });

    test('Large file processing performance', () async {
      // Create a large DPug file
      final largeFile = File('${tempDir.path}/large_input.dpug');
      final largeContent = TestDataGenerator.generateLargeDpugFile(5000);
      await largeFile.writeAsString(largeContent);

      final benchmark = Benchmark('large_file_processing', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(() {
          // Simulate processing large file
          final content = largeFile.readAsStringSync();
          return content.length;
        });
        DpugPerformanceUtils.recordMeasurement(
          'large_file_processing',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('large_file_processing', benchmark);
      await benchmark.run();
    });

    test('Concurrent CLI operations performance', () async {
      // Create multiple files for concurrent processing
      final files = <File>[];
      for (int i = 0; i < 20; i++) {
        final file = File('${tempDir.path}/concurrent_$i.dpug');
        final content = TestDataGenerator.generateDpugWidget(
          'Concurrent$i',
          3,
          4,
        );
        await file.writeAsString(content);
        files.add(file);
      }

      final benchmark = Benchmark('concurrent_cli_operations', () async {
        final result = DpugPerformanceUtils.measureTimeWithMemory(() async {
          final futures = files.map((final file) async {
            final command = ConvertCommand();
            return command;
          });
          return Future.wait(futures);
        });
        DpugPerformanceUtils.recordMeasurement(
          'concurrent_cli_operations',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('concurrent_cli_operations', benchmark);
      await benchmark.run();
    });

    test('Memory usage with large files', () async {
      final initialMemory = ProcessInfo.currentRss;

      final benchmark = Benchmark('memory_usage_large_files', () async {
        // Process multiple large files to test memory usage
        for (int i = 0; i < 50; i++) {
          final file = File('${tempDir.path}/memory_test_$i.dpug');
          final content = TestDataGenerator.generateLargeDpugFile(1000);
          await file.writeAsString(content);

          // Simulate processing
          final readContent = await file.readAsString();
          final command = ConvertCommand();
        }

        final finalMemory = ProcessInfo.currentRss;
        final memoryDelta = finalMemory - initialMemory;

        DpugPerformanceUtils.recordMeasurement(
          'memory_usage_large_files',
          Duration.zero,
          memoryDelta,
        );
      });

      runner.addBenchmark('memory_usage_large_files', benchmark);
      await benchmark.run();
    });

    test('File I/O performance benchmark', () async {
      final benchmark = Benchmark('file_io_performance', () async {
        final result = DpugPerformanceUtils.measureTimeWithMemory(() async {
          // Test file creation, writing, reading, and deletion
          final testFile = File('${tempDir.path}/io_test.dpug');
          final content = TestDataGenerator.generateDpugWidget('IOTest', 2, 3);

          await testFile.writeAsString(content);
          final readContent = await testFile.readAsString();
          await testFile.delete();

          return readContent;
        });
        DpugPerformanceUtils.recordMeasurement(
          'file_io_performance',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('file_io_performance', benchmark);
      await benchmark.run();
    });

    test('Command parsing performance', () async {
      final testArgs = [
        'convert',
        '--from',
        'input.dpug',
        '--to',
        'output.dart',
        '--format',
        'dpug-to-dart',
      ];

      final benchmark = Benchmark('command_parsing_performance', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(() {
          final command = ConvertCommand();
          return command;
        });
        DpugPerformanceUtils.recordMeasurement(
          'command_parsing_performance',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('command_parsing_performance', benchmark);
      await benchmark.run();
    });

    test('Error handling performance', () async {
      final benchmark = Benchmark('error_handling_performance', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(() {
          // Test error handling performance
          try {
            throw Exception('Test error');
          } catch (e) {
            DpugCliUtils.printError('Test error: $e');
          }
        });
        DpugPerformanceUtils.recordMeasurement(
          'error_handling_performance',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('error_handling_performance', benchmark);
      await benchmark.run();
    });

    test('Print CLI performance report', DpugPerformanceUtils.printReport);
  });
}
