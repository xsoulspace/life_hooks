#!/usr/bin/env dart

import 'dart:io';

import 'package:args/args.dart';
import 'package:dpug_core/compiler/performance_monitor.dart';

void main(final List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help')
    ..addFlag(
      'core',
      abbr: 'c',
      negatable: false,
      help: 'Run core compiler benchmarks',
    )
    ..addFlag(
      'builder',
      abbr: 'b',
      negatable: false,
      help: 'Run code builder benchmarks',
    )
    ..addFlag('cli', negatable: false, help: 'Run CLI benchmarks')
    ..addFlag(
      'widget',
      abbr: 'w',
      negatable: false,
      help: 'Run widget compilation benchmarks',
    )
    ..addFlag(
      'resource',
      abbr: 'r',
      negatable: false,
      help: 'Run resource usage tests',
    )
    ..addFlag('all', abbr: 'a', negatable: false, help: 'Run all benchmarks')
    ..addFlag(
      'monitor',
      abbr: 'm',
      negatable: false,
      help: 'Run performance monitoring',
    )
    ..addOption('output', abbr: 'o', help: 'Output directory for reports')
    ..addOption(
      'format',
      abbr: 'f',
      allowed: ['text', 'json', 'html'],
      defaultsTo: 'text',
      help: 'Report format',
    );

  final results = parser.parse(arguments);

  if (results['help'] as bool) {
    print('DPug Performance Benchmark Runner');
    print('');
    print('Usage: dart run bin/run_performance_benchmarks.dart [options]');
    print('');
    print('Options:');
    print(parser.usage);
    return;
  }

  final outputDir = results['output'] as String? ?? 'performance_reports';
  final format = results['format'] as String;

  // Create output directory
  await Directory(outputDir).create(recursive: true);

  print('🚀 DPug Performance Benchmark Suite');
  print('=====================================');

  try {
    if (results['all'] as bool || results['core'] as bool) {
      await _runCoreBenchmarks();
    }

    if (results['all'] as bool || results['builder'] as bool) {
      await _runBuilderBenchmarks();
    }

    if (results['all'] as bool || results['cli'] as bool) {
      await _runCLIBenchmarks();
    }

    if (results['all'] as bool || results['widget'] as bool) {
      await _runWidgetBenchmarks();
    }

    if (results['all'] as bool || results['resource'] as bool) {
      await _runResourceTests();
    }

    if (results['monitor'] as bool) {
      await _runPerformanceMonitoring();
    }

    await _generateReport(outputDir, format);

    print('\n✅ Benchmark suite completed successfully!');
    print('📊 Reports generated in: $outputDir');
  } catch (e, stackTrace) {
    print('❌ Benchmark suite failed: $e');
    print(stackTrace);
    exit(1);
  }
}

Future<void> _runCoreBenchmarks() async {
  print('\n📊 Running Core Compiler Benchmarks...');
  final result = await Process.run('dart', [
    'test',
    'test/core_compiler_performance_benchmark.dart',
    '--reporter=compact',
  ], workingDirectory: '/Users/antonio/xs/life_hooks/dp_packages/dpug_core');

  if (result.exitCode != 0) {
    print('Core benchmarks failed: ${result.stderr}');
  } else {
    print('✅ Core benchmarks completed');
  }
}

Future<void> _runBuilderBenchmarks() async {
  print('\n🔨 Running Code Builder Benchmarks...');
  final result = await Process.run(
    'dart',
    [
      'test',
      'test/code_builder_performance_benchmark.dart',
      '--reporter=compact',
    ],
    workingDirectory:
        '/Users/antonio/xs/life_hooks/dp_packages/dpug_code_builder',
  );

  if (result.exitCode != 0) {
    print('Code builder benchmarks failed: ${result.stderr}');
  } else {
    print('✅ Code builder benchmarks completed');
  }
}

Future<void> _runCLIBenchmarks() async {
  print('\n💻 Running CLI Benchmarks...');
  final result = await Process.run('dart', [
    'test',
    'test/cli_performance_benchmark.dart',
    '--reporter=compact',
  ], workingDirectory: '/Users/antonio/xs/life_hooks/dp_packages/dpug_cli');

  if (result.exitCode != 0) {
    print('CLI benchmarks failed: ${result.stderr}');
  } else {
    print('✅ CLI benchmarks completed');
  }
}

Future<void> _runWidgetBenchmarks() async {
  print('\n🎨 Running Widget Compilation Benchmarks...');
  final result = await Process.run('dart', [
    'test',
    'test/widget_compilation_performance_benchmark.dart',
    '--reporter=compact',
  ], workingDirectory: '/Users/antonio/xs/life_hooks/dp_packages/dpug_core');

  if (result.exitCode != 0) {
    print('Widget benchmarks failed: ${result.stderr}');
  } else {
    print('✅ Widget benchmarks completed');
  }
}

Future<void> _runResourceTests() async {
  print('\n🔍 Running Resource Usage Tests...');
  final result = await Process.run('dart', [
    'test',
    'test/resource_usage_test.dart',
    '--reporter=compact',
  ], workingDirectory: '/Users/antonio/xs/life_hooks/dp_packages/dpug_core');

  if (result.exitCode != 0) {
    print('Resource tests failed: ${result.stderr}');
  } else {
    print('✅ Resource tests completed');
  }
}

Future<void> _runPerformanceMonitoring() async {
  print('\n📈 Running Performance Monitoring...');
  final monitor = PerformanceMonitor();
  final report = await monitor.runMonitoring();
  monitor.printReport(report);
  print('✅ Performance monitoring completed');
}

Future<void> _generateReport(
  final String outputDir,
  final String format,
) async {
  print('\n📋 Generating Performance Report...');

  final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
  final reportFile = File('$outputDir/performance_report_$timestamp.$format');

  // This is a simplified report generation
  // In a real implementation, you would collect results from all benchmark runs
  final report =
      '''
DPug Performance Benchmark Report
==================================
Generated: $timestamp

This report contains performance benchmarks for:
- Core Compiler (DPug ↔ Dart conversion)
- Code Builder (Code generation, visitor patterns)
- CLI (File processing, startup time)
- Widget Compilation (Flutter widgets, stateful/stateless)
- Resource Usage (Memory leaks, file handles)

For detailed results, check the individual benchmark outputs above.

Recommendations:
1. Monitor for regressions in conversion times
2. Watch memory usage in large file processing
3. Ensure resource cleanup in CLI operations
4. Track widget compilation performance
''';

  await reportFile.writeAsString(report);
  print('✅ Report generated: ${reportFile.path}');
}
