import 'dart:io';

/// Performance utilities for DPug compiler benchmarking
class DpugPerformanceUtils {
  static final Map<String, List<Duration>> _measurements = {};
  static final Map<String, List<int>> _memoryMeasurements = {};

  /// Measure execution time of a function
  static Duration measureTime(final Function() fn) {
    final stopwatch = Stopwatch()..start();
    fn();
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  /// Measure execution time with memory usage
  static PerformanceResult measureTimeWithMemory(final Function() fn) {
    final beforeMemory = ProcessInfo.currentRss;

    final stopwatch = Stopwatch()..start();
    final result = fn();
    stopwatch.stop();

    final afterMemory = ProcessInfo.currentRss;
    final memoryDelta = afterMemory - beforeMemory;

    return PerformanceResult(
      duration: stopwatch.elapsed,
      memoryDelta: memoryDelta,
      result: result,
    );
  }

  /// Record a performance measurement
  static void recordMeasurement(
    final String name,
    final Duration duration, [
    final int? memoryBytes,
  ]) {
    _measurements.putIfAbsent(name, () => []).add(duration);
    if (memoryBytes != null) {
      _memoryMeasurements.putIfAbsent(name, () => []).add(memoryBytes);
    }
  }

  /// Get statistics for a measurement
  static MeasurementStats getStats(final String name) {
    final durations = _measurements[name];
    if (durations == null || durations.isEmpty) {
      throw ArgumentError('No measurements found for: $name');
    }

    final sorted = List<Duration>.from(durations)..sort();
    final total = sorted.fold(Duration.zero, (final a, final b) => a + b);
    final avg = total ~/ sorted.length;

    return MeasurementStats(
      name: name,
      count: sorted.length,
      min: sorted.first,
      max: sorted.last,
      average: avg,
      median: sorted[sorted.length ~/ 2],
      p95: sorted[(sorted.length * 0.95).toInt()],
      p99: sorted[(sorted.length * 0.99).toInt()],
      memoryStats: _getMemoryStats(name),
    );
  }

  static MemoryStats? _getMemoryStats(final String name) {
    final memories = _memoryMeasurements[name];
    if (memories == null || memories.isEmpty) return null;

    final sorted = List<int>.from(memories)..sort();
    final total = sorted.fold<int>(0, (final a, final b) => a + b);
    final avg = total ~/ sorted.length;

    return MemoryStats(
      min: sorted.first,
      max: sorted.last,
      average: avg,
      median: sorted[sorted.length ~/ 2],
      p95: sorted[(sorted.length * 0.95).toInt()],
      p99: sorted[(sorted.length * 0.99).toInt()],
    );
  }

  /// Clear all measurements
  static void clearMeasurements() {
    _measurements.clear();
    _memoryMeasurements.clear();
  }

  /// Print formatted performance report
  static void printReport() {
    print('\n=== DPug Performance Report ===\n');

    for (final name in _measurements.keys) {
      final stats = getStats(name);
      print('${stats.name}:');
      print('  Count: ${stats.count}');
      print('  Min: ${stats.min.inMicroseconds}μs');
      print('  Max: ${stats.max.inMicroseconds}μs');
      print('  Avg: ${stats.average.inMicroseconds}μs');
      print('  Median: ${stats.median.inMicroseconds}μs');
      print('  P95: ${stats.p95.inMicroseconds}μs');
      print('  P99: ${stats.p99.inMicroseconds}μs');

      if (stats.memoryStats != null) {
        print('  Memory (bytes):');
        print('    Min: ${stats.memoryStats!.min}');
        print('    Max: ${stats.memoryStats!.max}');
        print('    Avg: ${stats.memoryStats!.average}');
      }
      print('');
    }
  }
}

/// Performance result with timing and memory information
class PerformanceResult {
  const PerformanceResult({
    required this.duration,
    required this.memoryDelta,
    this.result,
  });

  final Duration duration;
  final int memoryDelta;
  final dynamic result;

  @override
  String toString() => '${duration.inMicroseconds}μs, $memoryDelta bytes';
}

/// Performance measurement statistics
class MeasurementStats {
  const MeasurementStats({
    required this.name,
    required this.count,
    required this.min,
    required this.max,
    required this.average,
    required this.median,
    required this.p95,
    required this.p99,
    this.memoryStats,
  });

  final String name;
  final int count;
  final Duration min;
  final Duration max;
  final Duration average;
  final Duration median;
  final Duration p95;
  final Duration p99;
  final MemoryStats? memoryStats;
}

/// Memory usage statistics
class MemoryStats {
  const MemoryStats({
    required this.min,
    required this.max,
    required this.average,
    required this.median,
    required this.p95,
    required this.p99,
  });

  final int min;
  final int max;
  final int average;
  final int median;
  final int p95;
  final int p99;
}

/// Benchmark runner with DPug-specific utilities
class DpugBenchmarkRunner {
  final Map<String, Benchmark> _benchmarks = {};

  void addBenchmark(final String name, final Benchmark benchmark) {
    _benchmarks[name] = benchmark;
  }

  Future<void> runAll({final bool printReport = true}) async {
    print('Running DPug Performance Benchmarks...\n');

    for (final entry in _benchmarks.entries) {
      print('Running ${entry.key}...');
      await entry.value.run();
    }

    if (printReport) {
      DpugPerformanceUtils.printReport();
    }
  }

  void clearResults() {
    DpugPerformanceUtils.clearMeasurements();
  }
}

/// Performance test data generators
class TestDataGenerator {
  static String generateDpugWidget(
    final String name,
    final int depth,
    final int children,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('@stateful');
    buffer.writeln('class $name');
    buffer.writeln('  @listen int counter = 0');

    buffer.writeln();
    buffer.writeln('  Widget get build =>');

    _generateWidgetTree(buffer, depth, children, 1);

    return buffer.toString();
  }

  static void _generateWidgetTree(
    final StringBuffer buffer,
    final int depth,
    final int children,
    final int currentDepth,
  ) {
    if (currentDepth > depth) return;

    final indent = '  ' * (currentDepth + 1);
    buffer.writeln('${indent}Column');
    buffer.writeln('$indent  ..children: [');

    for (int i = 0; i < children; i++) {
      final childIndent = '  ' * (currentDepth + 2);
      if (currentDepth == depth) {
        buffer.writeln('${childIndent}Text');
        buffer.writeln('$childIndent  ..text: "Item $i"');
      } else {
        buffer.writeln('${childIndent}Container');
        buffer.writeln('$childIndent  ..child:');
        _generateWidgetTree(buffer, depth, children, currentDepth + 1);
      }

      if (i < children - 1) buffer.write(',');
      buffer.writeln();
    }

    buffer.writeln('$indent  ]');
  }

  static String generateLargeDpugFile(final int lines) {
    final buffer = StringBuffer();

    buffer.writeln('@stateful');
    buffer.writeln('class LargeWidget');
    buffer.writeln('  @listen int counter = 0');

    buffer.writeln();
    buffer.writeln('  Widget get build =>');
    buffer.writeln('    Column');
    buffer.writeln('      ..children: [');

    for (int i = 0; i < lines ~/ 10; i++) {
      buffer.writeln('        Text');
      buffer.writeln('          ..text: "Line $i"');
      buffer.writeln('          ..style: TextStyle');
      buffer.writeln('            ..fontSize: 16.0');
      buffer.writeln('            ..color: Colors.black');
      if (i % 2 == 0) {
        buffer.writeln('        Container');
        buffer.writeln('          ..width: 100.0');
        buffer.writeln('          ..height: 50.0');
      }
      if (i < (lines ~/ 10) - 1) buffer.writeln('        ,');
    }

    buffer.writeln('      ]');

    return buffer.toString();
  }
}

/// Simple benchmark implementation since benchmark package is not available
class Benchmark {
  Benchmark(this.name, this._benchmarkFn, {final int iterations = 100})
    : _iterations = iterations;
  final String name;
  final Function() _benchmarkFn;
  final int _iterations;

  Future<void> run() async {
    final List<Duration> times = [];

    // Warmup run
    _benchmarkFn();

    // Actual benchmark runs
    for (int i = 0; i < _iterations; i++) {
      final stopwatch = Stopwatch()..start();
      _benchmarkFn();
      stopwatch.stop();
      times.add(stopwatch.elapsed);
    }

    // Record statistics
    times.sort();
    final total = times.fold(Duration.zero, (final a, final b) => a + b);
    final avg = total ~/ times.length;

    DpugPerformanceUtils.recordMeasurement(
      name,
      avg,
      0, // Memory measurement not implemented in simple version
    );
  }
}
