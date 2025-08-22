# DPug Performance Testing Infrastructure

This directory contains comprehensive performance tests and benchmarks for the DPug project. The performance testing suite is designed to monitor and prevent performance regressions across all components.

## 🏗️ Architecture

### Core Components

1. **Performance Utils** (`performance_utils.dart`)

   - Shared utilities for timing and memory measurement
   - Test data generators for consistent benchmarking
   - Statistics calculation and reporting

2. **Performance Monitor** (`performance_monitor.dart`)

   - Continuous performance monitoring
   - Regression detection
   - Historical performance tracking

3. **Benchmark Runner** (`bin/run_performance_benchmarks.dart`)
   - Unified command-line interface for running all benchmarks
   - Report generation in multiple formats

## 📊 Benchmark Categories

### 1. Core Compiler Performance

- **File**: `core_compiler_performance_benchmark.dart`
- **Metrics**: DPug→Dart conversion, Dart→DPug conversion, lexer, AST builder
- **Focus**: Parser performance, memory usage during conversion

### 2. Code Builder Performance

- **File**: `code_builder_performance_benchmark.dart` (in dpug_code_builder package)
- **Metrics**: Widget building, class generation, visitor patterns
- **Focus**: Code generation speed, memory efficiency

### 3. CLI Performance

- **File**: `cli_performance_benchmark.dart` (in dpug_cli package)
- **Metrics**: Startup time, file processing, concurrent operations
- **Focus**: User experience, resource usage

### 4. Widget Compilation Performance

- **File**: `widget_compilation_performance_benchmark.dart`
- **Metrics**: Stateful/stateless widgets, complex widget trees
- **Focus**: Flutter widget compilation efficiency

### 5. Resource Usage Testing

- **File**: `resource_usage_test.dart`
- **Metrics**: Memory leaks, file handle management, cleanup
- **Focus**: Resource exhaustion prevention

## 🚀 Running Benchmarks

### Quick Start

```bash
# Run all benchmarks
dart run dpug_core/bin/run_performance_benchmarks.dart --all

# Run specific benchmark category
dart run dpug_core/bin/run_performance_benchmarks.dart --core
dart run dpug_core/bin/run_performance_benchmarks.dart --builder
dart run dpug_core/bin/run_performance_benchmarks.dart --cli
dart run dpug_core/bin/run_performance_benchmarks.dart --widget
dart run dpug_core/bin/run_performance_benchmarks.dart --resource

# Run performance monitoring
dart run dpug_core/bin/run_performance_benchmarks.dart --monitor

# Generate HTML report
dart run dpug_core/bin/run_performance_benchmarks.dart --all --format html --output reports/
```

### Individual Benchmark Execution

```bash
# Core compiler benchmarks
cd dp_packages/dpug_core
dart test test/core_compiler_performance_benchmark.dart

# Code builder benchmarks
cd dp_packages/dpug_code_builder
dart test test/code_builder_performance_benchmark.dart

# CLI benchmarks
cd dp_packages/dpug_cli
dart test test/cli_performance_benchmark.dart
```

## 📈 Performance Metrics

### Timing Metrics

- **Min/Max/Average Duration**: Basic timing statistics
- **P95/P99 Percentiles**: Outlier analysis
- **Standard Deviation**: Performance consistency

### Memory Metrics

- **Memory Delta**: Memory usage change during operation
- **Peak Memory**: Maximum memory usage
- **Memory Leaks**: Detection of memory not being freed

### Resource Metrics

- **File Handles**: Open file descriptor tracking
- **Network Resources**: Connection cleanup verification
- **Temporary Files**: Cleanup verification

## 🔍 Performance Monitoring

### Regression Detection

The performance monitor automatically detects:

- **Performance Regressions**: >20% performance degradation
- **Memory Regressions**: >20% memory usage increase
- **Performance Improvements**: >10% performance gains

### Baseline Management

- Baselines are stored in `performance_baseline.json`
- Automatic baseline updates for stable/improved performance
- Historical tracking of performance trends

### Continuous Integration

```yaml
# Example GitHub Actions workflow
- name: Performance Tests
  run: |
    dart run dpug_core/bin/run_performance_benchmarks.dart --all --monitor
    # Check for regressions in CI
    if [performance_monitoring_detected_regressions]; then
      exit 1
    fi
```

## 📋 Benchmark Data

### Test Data Generators

The `TestDataGenerator` class provides:

- **Simple widgets**: Basic DPug widget structures
- **Complex widgets**: Nested widget trees with properties
- **Large files**: Generated files of specified line counts
- **Edge cases**: Unusual but valid DPug constructs

### Benchmark Scenarios

1. **Micro-benchmarks**: Individual operations (single widget conversion)
2. **Macro-benchmarks**: End-to-end workflows (file processing)
3. **Stress tests**: Large-scale operations (1000+ widgets)
4. **Concurrent tests**: Multi-threaded performance

## 🎯 Performance Targets

### Response Time Goals

- **Simple conversion**: < 1ms
- **Complex widget**: < 10ms
- **Large file**: < 100ms
- **CLI startup**: < 50ms

### Memory Usage Goals

- **Simple conversion**: < 1MB
- **Complex widget**: < 5MB
- **Large file**: < 50MB
- **No memory leaks**: Δmemory < 10% after repeated operations

### Resource Usage Goals

- **File handles**: Proper cleanup after operations
- **Temporary files**: Automatic cleanup
- **Network resources**: Connection pooling and cleanup

## 🛠️ Extending Benchmarks

### Adding New Benchmarks

1. **Create benchmark file** in appropriate package:

   ```dart
   test('my new benchmark', () async {
     final benchmark = Benchmark('my_metric', () {
       final result = DpugPerformanceUtils.measureTimeWithMemory(() {
         // Your test code here
         return myOperation();
       });
       DpugPerformanceUtils.recordMeasurement(
         'my_metric',
         result.duration,
         result.memoryDelta,
       );
     });

     runner.addBenchmark('my_metric', benchmark);
     await benchmark.run();
   });
   ```

2. **Update the benchmark runner** to include your new benchmark

3. **Add performance monitoring** for your metric

### Custom Metrics

```dart
// Add custom measurement
DpugPerformanceUtils.recordMeasurement(
  'custom_metric',
  duration,
  memoryUsage,
);

// Get statistics
final stats = DpugPerformanceUtils.getStats('custom_metric');
```

## 📊 Interpreting Results

### Performance Report Format

```
=== DPug Performance Report ===
simple_dpug_to_dart:
  Count: 100
  Min: 150μs
  Max: 250μs
  Avg: 180μs
  Median: 175μs
  P95: 220μs
  P99: 240μs
  Memory (bytes):
    Min: 1024
    Max: 2048
    Avg: 1536
```

### Status Indicators

- 🟢 **STABLE**: Performance within acceptable range
- 🔴 **REGRESSION**: Performance degraded beyond threshold
- 🟡 **IMPROVEMENT**: Performance improved significantly
- 🔵 **NEW_METRIC**: First time measuring this metric

## 🔧 Troubleshooting

### Common Issues

1. **High Memory Usage**

   - Check for object retention in loops
   - Verify proper cleanup of resources
   - Use memory profiling tools

2. **Slow Performance**

   - Profile with Dart DevTools
   - Check for algorithmic inefficiencies
   - Verify proper caching strategies

3. **Inconsistent Results**
   - Run benchmarks multiple times
   - Check system resource usage
   - Isolate benchmark environment

### Debugging Benchmarks

```bash
# Run with verbose output
dart run dpug_core/bin/run_performance_benchmarks.dart --all --verbose

# Profile specific benchmark
dart --observe test/core_compiler_performance_benchmark.dart
```

## 🤝 Contributing

When adding new features:

1. **Add performance tests** for new functionality
2. **Update baselines** after significant changes
3. **Monitor performance** in CI/CD pipelines
4. **Document performance characteristics**

## 📚 Further Reading

- [Dart Benchmark Package](https://pub.dev/packages/benchmark)
- [Dart Performance Best Practices](https://dart.dev/guides/language/effective-dart)
- [Flutter Performance Guide](https://docs.flutter.dev/perf)
