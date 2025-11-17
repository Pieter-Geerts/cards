import 'dart:async';

// dart:convert is not required here after YAML usage

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';

import '../helpers/logo_helper.dart';
import '../utils/simple_icons_mapping.dart';

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

  // Configurable whitelist for shop logos. Defaults to a curated set.
  // Can be overridden at runtime via `setShopWhitelist` or modified with
  // `addShopToWhitelist` / `removeShopFromWhitelist`.
  final Set<String> _shopWhitelist = {
    'carrefour',
    'aldinord',
    'lidl',
    'walmart',
    'target',
    'tesco',
    'albertheijn',
    'ikea',
    'nike',
    'adidas',
    'puma',
    'zara',
    'amazon',
    'ebay',
    'etsy',
    'shopify',
  };

  // Whether we've attempted to load a configurable whitelist from assets.
  bool _whitelistLoaded = false;

  // Optional override for asset bundle (useful in tests)
  AssetBundle? _assetBundle;

  /// Attempt to load a JSON array from assets/config/logo_whitelist.json.
  /// If present and valid, this replaces the in-code whitelist.
  /// Attempt to load a YAML configuration from `build-config.yaml`.
  /// If present and contains a top-level `logo_whitelist` list, it will
  /// replace the in-code whitelist. This is attempted only once per process
  /// unless `reloadWhitelistFromAssets()` is called.
  Future<void> _ensureWhitelistLoaded() async {
    _whitelistLoaded = true; // mark so we only try once per process
    try {
      // Check persisted user whitelist first
      try {
        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getStringList('logo_shop_whitelist');
        if (stored != null && stored.isNotEmpty) {
          setShopWhitelist(stored.toSet());
          return;
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Failed to read persisted whitelist: $e');
      }

      final bundle = _assetBundle ?? rootBundle;
      final data = await bundle.loadString('build-config.yaml');

      final doc = loadYaml(data);
      if (doc is YamlMap) {
        final dynamic wl = doc['logo_whitelist'];
        if (wl is YamlList) {
          final parsed = <String>{};
          for (final item in wl) {
            if (item is String) parsed.add(item);
          }
          if (parsed.isNotEmpty) setShopWhitelist(parsed);
        }
      }
    } catch (e) {
      // No asset present or parsing failed — silently continue with default
      if (kDebugMode) debugPrint('No external whitelist loaded: $e');
    }
  }

  /// Set a custom [AssetBundle] for the service. Intended for tests only.
  void setAssetBundleForTesting(AssetBundle bundle) {
    _assetBundle = bundle;
    // When the bundle changes we should allow reloading from assets
    _whitelistLoaded = false;
    _availableLogosCache.clear();
  }

  /// Force reloading the whitelist from assets. Useful in tests or when the
  /// configuration may have changed at runtime.
  Future<void> reloadWhitelistFromAssets() async {
    _whitelistLoaded = false;
    await _ensureWhitelistLoaded();
  }

  /// Returns a copy of the current shop whitelist.
  Set<String> getShopWhitelist() => Set<String>.from(_shopWhitelist);

  /// Replace the current shop whitelist with a new set of identifiers.
  void setShopWhitelist(Set<String> newWhitelist) {
    _shopWhitelist
      ..clear()
      ..addAll(newWhitelist);

    // Invalidate cache so consumers pick up the new filtering immediately
    _availableLogosCache.clear();
    // Persist the whitelist asynchronously
    _persistWhitelist();
  }

  /// Add a single shop identifier to the whitelist.
  void addShopToWhitelist(String identifier) {
    _shopWhitelist.add(identifier);
    _availableLogosCache.clear();
    _persistWhitelist();
  }

  /// Remove a single shop identifier from the whitelist.
  void removeShopFromWhitelist(String identifier) {
    _shopWhitelist.remove(identifier);
    _availableLogosCache.clear();
    _persistWhitelist();
  }

  Future<void> _persistWhitelist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('logo_shop_whitelist', _shopWhitelist.toList());
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to persist whitelist: $e');
    }
  }

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
    // Try to load a configurable whitelist from assets once. If the
    // asset is not present or loading fails, we fall back to the default
    // in-code whitelist.
    if (!_whitelistLoaded) {
      await _ensureWhitelistLoaded();
    }
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

      // Filter: only show logos that correspond to shops/retail.
      // We use the SimpleIcons identifier (e.g. 'simple_icon:amazon') to
      // determine the name and apply the configurable whitelist.
      final filtered = <IconData>[];
      for (final icon in logos) {
        final ident = SimpleIconsMapping.getIdentifier(icon);
        if (ident == null) continue;
        final name = ident.substring('simple_icon:'.length);
        if (_shopWhitelist.contains(name)) filtered.add(icon);
      }

      _availableLogosCache.clear();
      _availableLogosCache.addAll(filtered);

      // Preload first batch for immediate availability
      _preloadBatch(filtered.take(preloadBatchSize).toList());

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
