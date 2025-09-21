import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Service for monitoring app performance and providing metrics
/// Helps identify bottlenecks and optimize critical paths
class PerformanceMonitoringService {
  static final PerformanceMonitoringService _instance =
      PerformanceMonitoringService._internal();
  static PerformanceMonitoringService get instance => _instance;

  PerformanceMonitoringService._internal();

  final Map<String, Stopwatch> _activeTimers = {};
  final Map<String, List<int>> _metrics = {};
  final Map<String, int> _counters = {};

  bool _isEnabled = kDebugMode; // Only enable in debug mode by default

  /// Enable or disable performance monitoring
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Start timing an operation
  void startTimer(String operation) {
    if (!_isEnabled) return;

    _activeTimers[operation] = Stopwatch()..start();
  }

  /// Stop timing an operation and record the result
  int stopTimer(String operation) {
    if (!_isEnabled) return 0;

    final timer = _activeTimers.remove(operation);
    if (timer == null) {
      developer.log(
        'Warning: Timer for $operation was not started',
        name: 'Performance',
      );
      return 0;
    }

    timer.stop();
    final elapsed = timer.elapsedMilliseconds;

    // Record metric
    _metrics.putIfAbsent(operation, () => []).add(elapsed);

    // Log slow operations
    if (elapsed > 1000) {
      developer.log(
        'Slow operation detected: $operation took ${elapsed}ms',
        name: 'Performance',
      );
    }

    return elapsed;
  }

  /// Increment a counter
  void incrementCounter(String counter) {
    if (!_isEnabled) return;

    _counters[counter] = (_counters[counter] ?? 0) + 1;
  }

  /// Record a custom metric value
  void recordMetric(String metric, int value) {
    if (!_isEnabled) return;

    _metrics.putIfAbsent(metric, () => []).add(value);
  }

  /// Get performance statistics for a metric
  Map<String, dynamic> getMetricStats(String metric) {
    final values = _metrics[metric] ?? [];
    if (values.isEmpty) {
      return {'count': 0};
    }

    values.sort();
    final count = values.length;
    final sum = values.reduce((a, b) => a + b);
    final avg = sum / count;
    final median =
        count % 2 == 0
            ? (values[count ~/ 2 - 1] + values[count ~/ 2]) / 2
            : values[count ~/ 2].toDouble();

    return {
      'count': count,
      'average': avg.round(),
      'median': median.round(),
      'min': values.first,
      'max': values.last,
      'p95': values[(count * 0.95).floor()],
      'p99': values[(count * 0.99).floor()],
    };
  }

  /// Get all performance data
  Map<String, dynamic> getAllMetrics() {
    final result = <String, dynamic>{};

    // Add timer metrics
    for (final metric in _metrics.keys) {
      result[metric] = getMetricStats(metric);
    }

    // Add counters
    result['counters'] = Map.from(_counters);

    return result;
  }

  /// Clear all performance data
  void clearMetrics() {
    _activeTimers.clear();
    _metrics.clear();
    _counters.clear();
  }

  /// Log performance summary
  void logSummary() {
    if (!_isEnabled) return;

    developer.log('=== Performance Summary ===', name: 'Performance');

    // Log slow operations
    final slowOperations = <String>[];
    for (final entry in _metrics.entries) {
      final stats = getMetricStats(entry.key);
      if (stats['average'] > 500) {
        slowOperations.add('${entry.key}: ${stats['average']}ms avg');
      }
    }

    if (slowOperations.isNotEmpty) {
      developer.log('Slow operations:', name: 'Performance');
      for (final op in slowOperations) {
        developer.log('  - $op', name: 'Performance');
      }
    }

    // Log high-frequency operations
    final highFrequency = <String>[];
    for (final entry in _counters.entries) {
      if (entry.value > 100) {
        highFrequency.add('${entry.key}: ${entry.value} times');
      }
    }

    if (highFrequency.isNotEmpty) {
      developer.log('High-frequency operations:', name: 'Performance');
      for (final op in highFrequency) {
        developer.log('  - $op', name: 'Performance');
      }
    }

    developer.log('=== End Performance Summary ===', name: 'Performance');
  }

  /// Measure execution time of a function
  Future<T> measure<T>(String operation, Future<T> Function() function) async {
    startTimer(operation);
    try {
      final result = await function();
      return result;
    } finally {
      stopTimer(operation);
    }
  }

  /// Measure synchronous function execution
  T measureSync<T>(String operation, T Function() function) {
    startTimer(operation);
    try {
      final result = function();
      return result;
    } finally {
      stopTimer(operation);
    }
  }
}

/// Extension to easily measure widget build times
extension PerformanceWidget on Widget {
  Widget withPerformanceMonitoring(String widgetName) {
    return _PerformanceWrapper(widgetName: widgetName, child: this);
  }
}

class _PerformanceWrapper extends StatefulWidget {
  final String widgetName;
  final Widget child;

  const _PerformanceWrapper({required this.widgetName, required this.child});

  @override
  State<_PerformanceWrapper> createState() => _PerformanceWrapperState();
}

class _PerformanceWrapperState extends State<_PerformanceWrapper> {
  @override
  void initState() {
    super.initState();
    PerformanceMonitoringService.instance.incrementCounter(
      '${widget.widgetName}_builds',
    );
  }

  @override
  Widget build(BuildContext context) {
    return PerformanceMonitoringService.instance.measureSync(
      '${widget.widgetName}_build',
      () => widget.child,
    );
  }
}

/// Constants for common performance operations
class PerformanceMetrics {
  static const String logoLoad = 'logo_load';
  static const String logoSuggestion = 'logo_suggestion';
  static const String databaseQuery = 'database_query';
  static const String cardRender = 'card_render';
  static const String navigationTransition = 'navigation_transition';
  static const String searchFilter = 'search_filter';
  static const String cacheAccess = 'cache_access';
  static const String imageLoad = 'image_load';
  static const String barcodeScan = 'barcode_scan';
  static const String cardSave = 'card_save';
}
