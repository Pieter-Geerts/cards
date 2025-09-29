import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../helpers/logo_helper.dart';

/// High-performance caching service for logo operations
/// Implements intelligent preloading, memory management, and batch operations
class LogoCacheService {
  static final LogoCacheService _instance = LogoCacheService._internal();
  static LogoCacheService get instance => _instance;

  LogoCacheService._internal();

  // Cache storage with size limits to prevent memory bloat
  final Map<String, IconData> _suggestionCache = {};
  final List<IconData> _availableLogosCache = [];
  final Set<IconData> _preloadedLogos = {};

  // Cache metadata for intelligent eviction
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, int> _accessCounts = {};

  // Performance constants
  static const int maxCacheSize = 1000;
  static const Duration cacheExpiry = Duration(hours: 6);
  static const int preloadBatchSize = 50;

  // Loading states to prevent duplicate requests
  final Set<String> _loadingSuggestions = {};
  bool _loadingAvailableLogos = false;
  // Background timer for periodic cleanup. Stored so it can be cancelled
  // (useful for tests to avoid keeping the process alive).
  Timer? _cleanupTimer;

  /// Get suggested logo with performance monitoring and enhanced caching
  Future<IconData?> getSuggestedLogo(String title) async {
    if (title.isEmpty) return null;

    final key = title.toLowerCase().trim();

    // Performance monitoring
    final stopwatch = Stopwatch()..start();

    try {
      // Check cache first
      final cached = _suggestionCache[key];
      if (cached != null && !_isCacheExpired(key)) {
        // Update access metadata for LRU tracking
        _updateAccessMetadata(key);

        stopwatch.stop();
        if (stopwatch.elapsedMilliseconds > 100) {
          debugPrint(
            'Cache lookup took ${stopwatch.elapsedMilliseconds}ms for: $key',
          );
        }
        return cached;
      }

      // Prevent duplicate requests
      if (_loadingSuggestions.contains(key)) {
        while (_loadingSuggestions.contains(key)) {
          await Future.delayed(const Duration(milliseconds: 50));
        }
        return _suggestionCache[key];
      }

      _loadingSuggestions.add(key);

      try {
        // Compute suggestion with timeout protection
        final suggestion = await LogoHelper.suggestLogo(
          title,
        ).timeout(const Duration(seconds: 3), onTimeout: () => null);

        // Cache result with metadata
        if (suggestion != null) {
          _cacheLogoSuggestion(key, suggestion);
        }

        stopwatch.stop();
        if (stopwatch.elapsedMilliseconds > 500) {
          debugPrint(
            'Logo suggestion took ${stopwatch.elapsedMilliseconds}ms for: $key',
          );
        }

        return suggestion;
      } finally {
        _loadingSuggestions.remove(key);
      }
    } catch (e) {
      stopwatch.stop();
      debugPrint('Error getting logo suggestion for $title: $e');
      _loadingSuggestions.remove(key);
      return null;
    }
  }

  /// Check if cache entry is expired
  bool _isCacheExpired(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return true;
    return DateTime.now().difference(timestamp) > cacheExpiry;
  }

  /// Gets all available logos with intelligent caching
  Future<List<IconData>> getAllAvailableLogos() async {
    // Return cached results if available
    if (_availableLogosCache.isNotEmpty) {
      return List.from(_availableLogosCache);
    }

    // Prevent duplicate requests
    if (_loadingAvailableLogos) {
      while (_loadingAvailableLogos) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return List.from(_availableLogosCache);
    }

    _loadingAvailableLogos = true;

    try {
      final logos = await LogoHelper.getAllAvailableLogos();
      _availableLogosCache.clear();
      _availableLogosCache.addAll(logos);

      // Preload first batch for immediate availability
      _preloadBatch(logos.take(preloadBatchSize).toList());

      return List.from(_availableLogosCache);
    } finally {
      _loadingAvailableLogos = false;
    }
  }

  /// Preloads a batch of logos for smoother scrolling
  /// Uses background processing to avoid blocking main thread
  void preloadBatch(List<IconData> logos) {
    if (logos.isEmpty) return;

    // Run preloading in background to avoid blocking UI
    compute(_preloadLogosInBackground, logos);
  }

  /// Background computation for logo preloading
  static Future<void> _preloadLogosInBackground(List<IconData> logos) async {
    // Simulate preloading operations (icon data is already loaded in memory)
    // This could be enhanced to prefetch additional metadata or related icons
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Internal preload method for immediate processing
  void _preloadBatch(List<IconData> logos) {
    for (final logo in logos) {
      _preloadedLogos.add(logo);
    }
  }

  /// Caches a logo suggestion with metadata
  void _cacheLogoSuggestion(String key, IconData? suggestion) {
    if (suggestion == null) return;

    // Implement LRU eviction if cache is full
    if (_suggestionCache.length >= maxCacheSize) {
      _evictOldestEntries();
    }

    _suggestionCache[key] = suggestion;
    _cacheTimestamps[key] = DateTime.now();
    _accessCounts[key] = 1;
  }

  /// Updates access metadata for LRU cache management
  void _updateAccessMetadata(String key) {
    _accessCounts[key] = (_accessCounts[key] ?? 0) + 1;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// Evicts oldest cache entries based on LRU policy
  void _evictOldestEntries() {
    if (_suggestionCache.length < maxCacheSize) return;

    // Sort by access count and timestamp
    final sortedKeys =
        _suggestionCache.keys.toList()..sort((a, b) {
          final aCount = _accessCounts[a] ?? 0;
          final bCount = _accessCounts[b] ?? 0;

          if (aCount != bCount) {
            return aCount.compareTo(bCount); // Lower access count first
          }

          final aTime = _cacheTimestamps[a] ?? DateTime.now();
          final bTime = _cacheTimestamps[b] ?? DateTime.now();
          return aTime.compareTo(bTime); // Older timestamp first
        });

    // Remove oldest 20% of entries
    final entriesToRemove = (maxCacheSize * 0.2).round();
    for (int i = 0; i < entriesToRemove && i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      _suggestionCache.remove(key);
      _cacheTimestamps.remove(key);
      _accessCounts.remove(key);
    }
  }

  /// Clears expired cache entries
  void cleanupExpiredEntries() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) > cacheExpiry) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _suggestionCache.remove(key);
      _cacheTimestamps.remove(key);
      _accessCounts.remove(key);
    }
  }

  /// Prefetch suggestions for a list of card titles
  /// Useful for preloading suggestions when app starts
  Future<void> prefetchSuggestions(List<String> cardTitles) async {
    final futures = cardTitles.map((title) => getSuggestedLogo(title));
    await Future.wait(futures);
  }

  /// Clears all caches - useful for memory pressure or testing
  void clearCache() {
    _suggestionCache.clear();
    _availableLogosCache.clear();
    _preloadedLogos.clear();
    _cacheTimestamps.clear();
    _accessCounts.clear();
  }

  /// Gets cache statistics for debugging/monitoring
  Map<String, dynamic> getCacheStats() {
    return {
      'suggestionCacheSize': _suggestionCache.length,
      'availableLogosCount': _availableLogosCache.length,
      'preloadedLogosCount': _preloadedLogos.length,
      'totalCacheEntries': _cacheTimestamps.length,
      'oldestEntry':
          _cacheTimestamps.values.isEmpty
              ? null
              : _cacheTimestamps.values.reduce((a, b) => a.isBefore(b) ? a : b),
      'newestEntry':
          _cacheTimestamps.values.isEmpty
              ? null
              : _cacheTimestamps.values.reduce((a, b) => a.isAfter(b) ? a : b),
    };
  }

  /// Initializes the cache service with background cleanup
  void initialize() {
    // Set up periodic cache cleanup
    _cleanupTimer = Timer.periodic(const Duration(hours: 1), (_) {
      cleanupExpiredEntries();
    });

    // Preload common logos
    Future.microtask(() async {
      try {
        await getAllAvailableLogos();
      } catch (e) {
        debugPrint('Failed to preload logos: $e');
      }
    });
  }

  /// Dispose resources started by this service (timers, isolates, etc.).
  /// Tests should call this when they want to ensure no background
  /// asynchronous handles remain.
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }
}
