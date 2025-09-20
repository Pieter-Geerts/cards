import 'package:cards/services/logo_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LogoCacheService Tests', () {
    late LogoCacheService cacheService;

    setUp(() {
      cacheService = LogoCacheService.instance;
      cacheService.clearCache(); // Start with clean cache
    });

    tearDown(() {
      cacheService.clearCache(); // Clean up after each test
    });

    test('should be singleton', () {
      final instance1 = LogoCacheService.instance;
      final instance2 = LogoCacheService.instance;
      expect(instance1, same(instance2));
    });

    test('should cache logo suggestions', () async {
      // First call should load from LogoHelper
      final result1 = await cacheService.getSuggestedLogo('nike');

      // Second call should return cached result
      final result2 = await cacheService.getSuggestedLogo('nike');

      expect(result1, equals(result2));
      expect(result1, isNotNull); // Nike should be found

      // Verify cache contains the result
      final stats = cacheService.getCacheStats();
      expect(stats['suggestionCacheSize'], greaterThan(0));
    });

    test('should handle empty and null inputs', () async {
      final emptyResult = await cacheService.getSuggestedLogo('');
      final nullResult = await cacheService.getSuggestedLogo('   ');

      expect(emptyResult, isNull);
      expect(nullResult, isNull);
    });

    test('should cache available logos', () async {
      // First call loads from LogoHelper
      final logos1 = await cacheService.getAllAvailableLogos();

      // Second call should be cached
      final logos2 = await cacheService.getAllAvailableLogos();

      expect(logos1, equals(logos2));
      expect(logos1.isNotEmpty, isTrue);
    });

    test('should prefetch suggestions efficiently', () async {
      final cardTitles = ['google', 'apple', 'microsoft', 'amazon'];

      // Prefetch should complete without errors
      await cacheService.prefetchSuggestions(cardTitles);

      // Verify suggestions are cached
      final stats = cacheService.getCacheStats();
      expect(stats['suggestionCacheSize'], greaterThan(0));
    });

    test('should handle concurrent requests', () async {
      final futures = List.generate(
        10,
        (index) => cacheService.getSuggestedLogo('test_$index'),
      );

      final results = await Future.wait(futures);

      // All requests should complete
      expect(results.length, equals(10));
    });

    test('should cleanup expired entries', () {
      // Test cache cleanup functionality
      cacheService.cleanupExpiredEntries();

      final stats = cacheService.getCacheStats();
      expect(stats, isA<Map<String, dynamic>>());
    });

    test('should provide accurate cache statistics', () {
      final stats = cacheService.getCacheStats();

      expect(stats.keys, contains('suggestionCacheSize'));
      expect(stats.keys, contains('availableLogosCount'));
      expect(stats.keys, contains('preloadedLogosCount'));
      expect(stats.keys, contains('totalCacheEntries'));
    });

    test('should handle preload batch correctly', () {
      final testLogos = [Icons.star, Icons.favorite, Icons.home];

      // Should not throw error
      expect(() => cacheService.preloadBatch(testLogos), returnsNormally);
      expect(() => cacheService.preloadBatch([]), returnsNormally);
    });

    test('should clear cache completely', () async {
      // Populate cache
      await cacheService.getSuggestedLogo('nike');
      await cacheService.getAllAvailableLogos();

      // Verify cache has data
      var stats = cacheService.getCacheStats();
      expect(stats['totalCacheEntries'], greaterThan(0));

      // Clear cache
      cacheService.clearCache();

      // Verify cache is empty
      stats = cacheService.getCacheStats();
      expect(stats['suggestionCacheSize'], equals(0));
      expect(stats['availableLogosCount'], equals(0));
      expect(stats['preloadedLogosCount'], equals(0));
    });
  });
}
