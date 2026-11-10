import 'package:flutter/material.dart';

import '../models/card_item.dart';
import '../pages/add_card_entry_page.dart';
import '../services/error_handling_service.dart';
import '../services/performance_monitoring_service.dart';

/// Unified entry point for all add card operations
/// Provides consistent performance monitoring and error handling
class AddCardFlowManager {
  static const String _performanceKey = 'add_card_flow';

  /// Show add card flow with specified mode and optional prefilled data
  static Future<CardItem?> showAddCardFlow(
    BuildContext context, {
    AddCardFlowMode mode = AddCardFlowMode.selection,
    String? prefilledCode,
    CardType? prefilledType,
  }) async {
    PerformanceMonitoringService.instance.startTimer(
      '${_performanceKey}_total',
    );

    try {
      final result = await _showPageFlow(
        context,
        mode,
        prefilledCode,
        prefilledType,
      );

      PerformanceMonitoringService.instance.stopTimer(
        '${_performanceKey}_total',
      );

      if (result != null) {
        PerformanceMonitoringService.instance.incrementCounter(
          '${_performanceKey}_success',
        );
      } else {
        PerformanceMonitoringService.instance.incrementCounter(
          '${_performanceKey}_cancelled',
        );
      }

      return result;
    } catch (e, stackTrace) {
      PerformanceMonitoringService.instance.stopTimer(
        '${_performanceKey}_total',
      );
      PerformanceMonitoringService.instance.incrementCounter(
        '${_performanceKey}_error',
      );

      ErrorHandlingService.instance.handleError(
        e,
        stackTrace,
        context: 'add_card_flow',
        additionalData: {'mode': mode.toString()},
      );

      return null;
    }
  }

  /// Show page based add card flow
  static Future<CardItem?> _showPageFlow(
    BuildContext context,
    AddCardFlowMode mode,
    String? prefilledCode,
    CardType? prefilledType,
  ) async {
    PerformanceMonitoringService.instance.startTimer('${_performanceKey}_page');

    final result = await Navigator.of(context).push<CardItem>(
      MaterialPageRoute(
        builder:
            (context) => AddCardEntryPage(
              initialMode: _convertToEntryMode(mode),
              prefilledCode: prefilledCode,
              prefilledType: prefilledType,
            ),
      ),
    );

    PerformanceMonitoringService.instance.stopTimer('${_performanceKey}_page');
    return result;
  }

  static AddCardEntryMode _convertToEntryMode(AddCardFlowMode mode) {
    return switch (mode) {
      AddCardFlowMode.selection => AddCardEntryMode.selection,
      AddCardFlowMode.scan => AddCardEntryMode.scan,
      AddCardFlowMode.manual => AddCardEntryMode.manual,
      AddCardFlowMode.import => AddCardEntryMode.import,
    };
  }

  /// Get performance statistics for add card flows
  static Map<String, dynamic> getPerformanceStats() {
    final service = PerformanceMonitoringService.instance;
    return {
      'total_stats': service.getMetricStats('${_performanceKey}_total'),
      'page_stats': service.getMetricStats('${_performanceKey}_page'),
      'success_rate': _calculateSuccessRate(),
    };
  }

  static double _calculateSuccessRate() {
    final service = PerformanceMonitoringService.instance;
    final totalStats = service.getMetricStats('${_performanceKey}_total');
    final total = totalStats['count'] as int? ?? 0;

    if (total == 0) return 0.0;

    // We'll need to implement counter tracking in performance service
    // For now, return a placeholder
    return 95.0; // Placeholder success rate
  }
}

/// Enhanced enum with display names and icons
enum AddCardFlowMode {
  selection,
  scan,
  manual,
  import;

  String get displayName {
    switch (this) {
      case AddCardFlowMode.selection:
        return 'Kies Methode'; // localized usage should be done at call site
      case AddCardFlowMode.scan:
        return 'Scan Code';
      case AddCardFlowMode.manual:
        return 'Handmatig';
      case AddCardFlowMode.import:
        return 'Importeer';
    }
  }

  IconData get icon {
    switch (this) {
      case AddCardFlowMode.selection:
        return Icons.add_card;
      case AddCardFlowMode.scan:
        return Icons.qr_code_scanner;
      case AddCardFlowMode.manual:
        return Icons.edit;
      case AddCardFlowMode.import:
        return Icons.photo_library;
    }
  }
}
