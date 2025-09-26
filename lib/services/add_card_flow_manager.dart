import 'package:flutter/material.dart';

import '../models/card_item.dart';
import '../pages/add_card_entry_page.dart' show AddCardMode;
import '../pages/add_card_form_page.dart';
import '../services/error_handling_service.dart';
import '../services/performance_monitoring_service.dart';
import '../widgets/add_card_bottom_sheet.dart';

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
    bool useBottomSheet = false,
  }) async {
    PerformanceMonitoringService.instance.startTimer(
      '${_performanceKey}_total',
    );

    try {
      CardItem? result;

      if (useBottomSheet) {
        result = await _showBottomSheetFlow(
          context,
          mode,
          prefilledCode,
          prefilledType,
        );
      } else {
        result = await _showPageFlow(
          context,
          mode,
          prefilledCode,
          prefilledType,
        );
      }

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
        additionalData: {
          'mode': mode.toString(),
          'useBottomSheet': useBottomSheet.toString(),
        },
      );

      return null;
    }
  }

  /// Show bottom sheet based add card flow
  static Future<CardItem?> _showBottomSheetFlow(
    BuildContext context,
    AddCardFlowMode mode,
    String? prefilledCode,
    CardType? prefilledType,
  ) async {
    PerformanceMonitoringService.instance.startTimer(
      '${_performanceKey}_bottom_sheet',
    );

    CardItem? result;

    final completer = await showModalBottomSheet<CardItem?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => AddCardBottomSheet(
            onCardCreated: (card) {
              result = card;
              Navigator.of(context).pop(card);
            },
          ),
    );

    PerformanceMonitoringService.instance.stopTimer(
      '${_performanceKey}_bottom_sheet',
    );
    return result ?? completer;
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
        builder: (context) => AddCardFormPage(mode: _convertToPageMode(mode)),
      ),
    );

    PerformanceMonitoringService.instance.stopTimer('${_performanceKey}_page');
    return result;
  }

  /// Convert unified mode to page-specific mode
  static AddCardMode _convertToPageMode(AddCardFlowMode mode) {
    switch (mode) {
      case AddCardFlowMode.scan:
        return AddCardMode.scan;
      case AddCardFlowMode.manual:
        return AddCardMode.manual;
      case AddCardFlowMode.import:
        return AddCardMode.gallery; // Map import to gallery
      case AddCardFlowMode.selection:
        return AddCardMode.scan; // Default fallback
    }
  }

  /// Get performance statistics for add card flows
  static Map<String, dynamic> getPerformanceStats() {
    final service = PerformanceMonitoringService.instance;
    return {
      'total_stats': service.getMetricStats('${_performanceKey}_total'),
      'bottom_sheet_stats': service.getMetricStats(
        '${_performanceKey}_bottom_sheet',
      ),
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
