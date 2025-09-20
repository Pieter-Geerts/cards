import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Production-ready error handling service
/// Provides centralized error logging, user-friendly error messages,
/// and graceful degradation strategies
class ErrorHandlingService {
  static final ErrorHandlingService _instance =
      ErrorHandlingService._internal();
  static ErrorHandlingService get instance => _instance;

  ErrorHandlingService._internal();

  // Error tracking
  final List<AppError> _errorHistory = [];
  static const int maxErrorHistory = 100;

  /// Handle and log application errors
  void handleError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
    bool isFatal = false,
  }) {
    final appError = AppError(
      error: error,
      stackTrace: stackTrace,
      context: context,
      additionalData: additionalData,
      timestamp: DateTime.now(),
      isFatal: isFatal,
    );

    // Add to history
    _addToHistory(appError);

    // Log based on build mode
    if (kDebugMode) {
      _logDebugError(appError);
    } else {
      _logProductionError(appError);
    }

    // In production, you might want to send to crash reporting service
    // _sendToCrashlytics(appError);
  }

  /// Handle logo cache errors specifically
  void handleLogoCacheError(dynamic error, {String? operation}) {
    handleError(
      error,
      StackTrace.current,
      context: 'LogoCacheService',
      additionalData: {'operation': operation},
      isFatal: false,
    );
  }

  /// Handle navigation errors
  void handleNavigationError(dynamic error, {String? route}) {
    handleError(
      error,
      StackTrace.current,
      context: 'Navigation',
      additionalData: {'route': route},
      isFatal: false,
    );
  }

  /// Handle database errors
  void handleDatabaseError(dynamic error, {String? query}) {
    handleError(
      error,
      StackTrace.current,
      context: 'Database',
      additionalData: {'query': query},
      isFatal: false,
    );
  }

  /// Get user-friendly error message
  String getUserFriendlyMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'Operation timed out. Please check your connection and try again.';
    } else if (error is FormatException) {
      return 'Invalid data format. Please try again.';
    } else if (error.toString().contains('SocketException')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.toString().contains('Database')) {
      return 'Storage error. Please restart the app and try again.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  /// Get error statistics for monitoring
  Map<String, dynamic> getErrorStats() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));

    final recentErrors =
        _errorHistory
            .where((error) => error.timestamp.isAfter(last24Hours))
            .toList();

    final errorsByContext = <String, int>{};
    for (final error in recentErrors) {
      final context = error.context ?? 'Unknown';
      errorsByContext[context] = (errorsByContext[context] ?? 0) + 1;
    }

    return {
      'totalErrors': _errorHistory.length,
      'recentErrors': recentErrors.length,
      'errorsByContext': errorsByContext,
      'fatalErrors': _errorHistory.where((e) => e.isFatal).length,
    };
  }

  void _addToHistory(AppError error) {
    _errorHistory.add(error);

    // Keep only recent errors
    if (_errorHistory.length > maxErrorHistory) {
      _errorHistory.removeAt(0);
    }
  }

  void _logDebugError(AppError error) {
    developer.log(
      'Error in ${error.context ?? 'Unknown'}',
      name: 'CardsApp',
      error: error.error,
      stackTrace: error.stackTrace,
      level: error.isFatal ? 1000 : 900, // SEVERE : WARNING
    );

    if (kDebugMode) {
      debugPrint('🚨 Error: ${error.error}');
      if (error.context != null) {
        debugPrint('📍 Context: ${error.context}');
      }
      if (error.additionalData != null) {
        debugPrint('📊 Data: ${error.additionalData}');
      }
    }
  }

  void _logProductionError(AppError error) {
    // In production, log essential information only
    developer.log(
      'App Error',
      name: 'CardsApp',
      error: error.error.toString(),
      level: error.isFatal ? 1000 : 800,
    );
  }

  /// Clear error history (for testing)
  void clearHistory() {
    _errorHistory.clear();
  }
}

/// Represents an application error with context
class AppError {
  final dynamic error;
  final StackTrace? stackTrace;
  final String? context;
  final Map<String, dynamic>? additionalData;
  final DateTime timestamp;
  final bool isFatal;

  AppError({
    required this.error,
    this.stackTrace,
    this.context,
    this.additionalData,
    required this.timestamp,
    this.isFatal = false,
  });

  @override
  String toString() {
    return 'AppError(context: $context, error: $error, timestamp: $timestamp)';
  }
}

/// Custom timeout exception
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  TimeoutException(this.message, this.timeout);

  @override
  String toString() =>
      'TimeoutException: $message (timeout: ${timeout.inSeconds}s)';
}

/// Global error handler setup
void setupGlobalErrorHandling() {
  // Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    ErrorHandlingService.instance.handleError(
      details.exception,
      details.stack,
      context: 'Flutter Framework',
      additionalData: {
        'library': details.library,
        'context': details.context?.toString(),
      },
      isFatal: details.silent == false,
    );
  };

  // Handle platform dispatch errors
  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorHandlingService.instance.handleError(
      error,
      stack,
      context: 'Platform',
      isFatal: true,
    );
    return true;
  };
}
