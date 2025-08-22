import 'dart:convert';
import 'dart:io';

import 'performance_utils.dart';

/// Continuous performance monitoring and regression detection
class PerformanceMonitor {
  static const String _baselineFile = 'performance_baseline.json';
  static const double _regressionThreshold = 1.2; // 20% degradation
  static const double _improvementThreshold = 0.9; // 10% improvement

  final Map<String, PerformanceBaseline> _baselines = {};

  /// Load existing performance baselines
  Future<void> loadBaselines() async {
    final file = File(_baselineFile);
    if (await file.exists()) {
      final content = await file.readAsString();
      final data = json.decode(content) as Map<String, dynamic>;

      _baselines.clear();
      data.forEach((final key, final value) {
        _baselines[key] = PerformanceBaseline.fromJson(
          value as Map<String, dynamic>,
        );
      });
    }
  }

  /// Save current performance baselines
  Future<void> saveBaselines() async {
    final data = <String, dynamic>{};
    _baselines.forEach((final key, final baseline) {
      data[key] = baseline.toJson();
    });

    final file = File(_baselineFile);
    await file.writeAsString(json.encode(data));
  }

  /// Update baseline with current performance data
  void updateBaseline(
    final String metric,
    final Duration duration,
    final int memoryBytes,
  ) {
    _baselines[metric] = PerformanceBaseline(
      averageDuration: duration,
      averageMemory: memoryBytes,
      lastUpdated: DateTime.now(),
    );
  }

  /// Check for performance regressions
  PerformanceReport checkForRegressions(
    final String metric,
    final Duration currentDuration,
    final int currentMemory,
  ) {
    final baseline = _baselines[metric];

    if (baseline == null) {
      return PerformanceReport(
        metric: metric,
        status: PerformanceStatus.newMetric,
        currentDuration: currentDuration,
        currentMemory: currentMemory,
      );
    }

    final durationRatio =
        currentDuration.inMicroseconds /
        baseline.averageDuration.inMicroseconds;
    final memoryRatio = currentMemory / baseline.averageMemory;

    PerformanceStatus status;
    String? message;

    if (durationRatio > _regressionThreshold) {
      status = PerformanceStatus.regression;
      message =
          'Performance regression detected: ${((durationRatio - 1) * 100).toStringAsFixed(1)}% slower';
    } else if (durationRatio < _improvementThreshold) {
      status = PerformanceStatus.improvement;
      message =
          'Performance improvement detected: ${((1 - durationRatio) * 100).toStringAsFixed(1)}% faster';
    } else if (memoryRatio > _regressionThreshold) {
      status = PerformanceStatus.regression;
      message =
          'Memory regression detected: ${((memoryRatio - 1) * 100).toStringAsFixed(1)}% more memory usage';
    } else {
      status = PerformanceStatus.stable;
    }

    return PerformanceReport(
      metric: metric,
      status: status,
      message: message,
      currentDuration: currentDuration,
      currentMemory: currentMemory,
      baselineDuration: baseline.averageDuration,
      baselineMemory: baseline.averageMemory,
      durationRatio: durationRatio,
      memoryRatio: memoryRatio,
    );
  }

  /// Run comprehensive performance monitoring
  Future<MonitoringReport> runMonitoring() async {
    await loadBaselines();

    final reports = <PerformanceReport>[];
    const stats = DpugPerformanceUtils.getStats;

    // Monitor all recorded metrics
    for (final metric in DpugPerformanceUtils._measurements.keys) {
      final metricStats = DpugPerformanceUtils.getStats(metric);
      final report = checkForRegressions(
        metric,
        metricStats.average,
        metricStats.memoryStats?.average ?? 0,
      );
      reports.add(report);

      // Update baseline if performance is stable or improved
      if (report.status == PerformanceStatus.stable ||
          report.status == PerformanceStatus.improvement) {
        updateBaseline(
          metric,
          metricStats.average,
          metricStats.memoryStats?.average ?? 0,
        );
      }
    }

    await saveBaselines();

    return MonitoringReport(
      timestamp: DateTime.now(),
      reports: reports,
      summary: _generateSummary(reports),
    );
  }

  String _generateSummary(final List<PerformanceReport> reports) {
    final regressions = reports
        .where((final r) => r.status == PerformanceStatus.regression)
        .length;
    final improvements = reports
        .where((final r) => r.status == PerformanceStatus.improvement)
        .length;
    final newMetrics = reports
        .where((final r) => r.status == PerformanceStatus.newMetric)
        .length;
    final stable = reports
        .where((final r) => r.status == PerformanceStatus.stable)
        .length;

    return 'Performance Summary: $regressions regressions, $improvements improvements, '
        '$newMetrics new metrics, $stable stable';
  }

  /// Print monitoring report
  void printReport(final MonitoringReport report) {
    print('\n=== Performance Monitoring Report ===');
    print('Timestamp: ${report.timestamp}');
    print('Summary: ${report.summary}\n');

    for (final r in report.reports) {
      print('${r.metric}:');
      print('  Status: ${r.status.name}');
      if (r.message != null) {
        print('  Message: ${r.message}');
      }
      print(
        '  Current: ${r.currentDuration.inMicroseconds}μs, ${r.currentMemory} bytes',
      );
      if (r.baselineDuration != null) {
        print(
          '  Baseline: ${r.baselineDuration!.inMicroseconds}μs, ${r.baselineMemory} bytes',
        );
      }
      if (r.durationRatio != null) {
        print('  Duration Ratio: ${r.durationRatio!.toStringAsFixed(2)}x');
      }
      print('');
    }
  }
}

/// Performance baseline data
class PerformanceBaseline {
  const PerformanceBaseline({
    required this.averageDuration,
    required this.averageMemory,
    required this.lastUpdated,
  });

  factory PerformanceBaseline.fromJson(final Map<String, dynamic> json) =>
      PerformanceBaseline(
        averageDuration: Duration(microseconds: json['averageDuration'] as int),
        averageMemory: json['averageMemory'] as int,
        lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      );
  final Duration averageDuration;
  final int averageMemory;
  final DateTime lastUpdated;

  Map<String, dynamic> toJson() => {
    'averageDuration': averageDuration.inMicroseconds,
    'averageMemory': averageMemory,
    'lastUpdated': lastUpdated.toIso8601String(),
  };
}

/// Performance status enum
enum PerformanceStatus {
  stable('STABLE'),
  regression('REGRESSION'),
  improvement('IMPROVEMENT'),
  newMetric('NEW_METRIC');

  final String name;
  const PerformanceStatus(this.name);
}

/// Performance report for a single metric
class PerformanceReport {
  const PerformanceReport({
    required this.metric,
    required this.status,
    required this.currentDuration,
    required this.currentMemory,
    this.message,
    this.baselineDuration,
    this.baselineMemory,
    this.durationRatio,
    this.memoryRatio,
  });
  final String metric;
  final PerformanceStatus status;
  final String? message;
  final Duration currentDuration;
  final int currentMemory;
  final Duration? baselineDuration;
  final int? baselineMemory;
  final double? durationRatio;
  final double? memoryRatio;
}

/// Complete monitoring report
class MonitoringReport {
  const MonitoringReport({
    required this.timestamp,
    required this.reports,
    required this.summary,
  });
  final DateTime timestamp;
  final List<PerformanceReport> reports;
  final String summary;
}
