import 'package:benchmark/benchmark.dart';
import 'package:dpug_core/compiler/ast_builder.dart';
import 'package:dpug_core/compiler/dpug_converter.dart';
import 'package:dpug_core/compiler/lexer.dart';
import 'package:dpug_core/compiler/performance_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Core Compiler Performance Benchmarks', () {
    late DpugConverter converter;
    late DpugBenchmarkRunner runner;

    setUp(() {
      converter = DpugConverter();
      runner = DpugBenchmarkRunner();
    });

    tearDown(() {
      runner.clearResults();
    });

    test('Simple DPug to Dart conversion benchmark', () async {
      const simpleDpug = '''
Text
  ..text: "Hello World"
''';

      await runner.runAll();
      final benchmark = Benchmark('simple_dpug_to_dart', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(
          () => converter.dpugToDart(simpleDpug),
        );
        DpugPerformanceUtils.recordMeasurement(
          'simple_dpug_to_dart',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('simple_dpug_to_dart', benchmark);
      await benchmark.run();
    });

    test('Complex DPug to Dart conversion benchmark', () async {
      final complexDpug = TestDataGenerator.generateDpugWidget(
        'ComplexWidget',
        3,
        5,
      );

      final benchmark = Benchmark('complex_dpug_to_dart', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(
          () => converter.dpugToDart(complexDpug),
        );
        DpugPerformanceUtils.recordMeasurement(
          'complex_dpug_to_dart',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('complex_dpug_to_dart', benchmark);
      await benchmark.run();
    });

    test('Large DPug file conversion benchmark', () async {
      final largeDpug = TestDataGenerator.generateLargeDpugFile(1000);

      final benchmark = Benchmark('large_dpug_to_dart', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(
          () => converter.dpugToDart(largeDpug),
        );
        DpugPerformanceUtils.recordMeasurement(
          'large_dpug_to_dart',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('large_dpug_to_dart', benchmark);
      await benchmark.run();
    });

    test('Dart to DPug conversion benchmark', () async {
      const dartCode = '''
class MyWidget extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Text("Hello World");
  }
}
''';

      final benchmark = Benchmark('dart_to_dpug', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(
          () => converter.dartToDpug(dartCode),
        );
        DpugPerformanceUtils.recordMeasurement(
          'dart_to_dpug',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('dart_to_dpug', benchmark);
      await benchmark.run();
    });

    test('Lexer performance benchmark', () async {
      final largeDpug = TestDataGenerator.generateLargeDpugFile(1000);

      final benchmark = Benchmark('lexer_performance', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(
          () => Lexer(largeDpug).tokenize(),
        );
        DpugPerformanceUtils.recordMeasurement(
          'lexer_performance',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('lexer_performance', benchmark);
      await benchmark.run();
    });

    test('AST Builder performance benchmark', () async {
      final largeDpug = TestDataGenerator.generateLargeDpugFile(1000);
      final tokens = Lexer(largeDpug).tokenize();

      final benchmark = Benchmark('ast_builder_performance', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(
          () => ASTBuilder(tokens).build(),
        );
        DpugPerformanceUtils.recordMeasurement(
          'ast_builder_performance',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('ast_builder_performance', benchmark);
      await benchmark.run();
    });

    test('Round-trip conversion benchmark', () async {
      final originalDpug = TestDataGenerator.generateDpugWidget(
        'RoundTripWidget',
        2,
        3,
      );

      final benchmark = Benchmark('round_trip_conversion', () {
        final result = DpugPerformanceUtils.measureTimeWithMemory(() {
          final dart = converter.dpugToDart(originalDpug);
          return converter.dartToDpug(dart);
        });
        DpugPerformanceUtils.recordMeasurement(
          'round_trip_conversion',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('round_trip_conversion', benchmark);
      await benchmark.run();
    });

    test('Concurrent conversion performance', () async {
      final dpugInputs = List.generate(
        10,
        (final i) =>
            TestDataGenerator.generateDpugWidget('ConcurrentWidget$i', 2, 3),
      );

      final benchmark = Benchmark('concurrent_conversion', () async {
        final result = DpugPerformanceUtils.measureTimeWithMemory(() async {
          final futures = dpugInputs.map(
            (final dpug) => Future(() => converter.dpugToDart(dpug)),
          );
          return Future.wait(futures);
        });
        DpugPerformanceUtils.recordMeasurement(
          'concurrent_conversion',
          result.duration,
          result.memoryDelta,
        );
      });

      runner.addBenchmark('concurrent_conversion', benchmark);
      await benchmark.run();
    });

    test('Memory leak detection benchmark', () async {
      final initialMemory = ProcessInfo.currentRss;

      final benchmark = Benchmark('memory_leak_detection', () {
        // Run multiple conversions to check for memory leaks
        for (int i = 0; i < 100; i++) {
          final dpug = TestDataGenerator.generateDpugWidget('LeakTest$i', 2, 3);
          converter.dpugToDart(dpug);
        }

        final finalMemory = ProcessInfo.currentRss;
        final memoryDelta = finalMemory - initialMemory;

        DpugPerformanceUtils.recordMeasurement(
          'memory_leak_detection',
          Duration.zero,
          memoryDelta,
        );
      });

      runner.addBenchmark('memory_leak_detection', benchmark);
      await benchmark.run();
    });

    test('Print performance report', DpugPerformanceUtils.printReport);
  });
}
