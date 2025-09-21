import 'package:cards/main.dart';
import 'package:cards/services/logo_cache_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Performance test app to verify optimizations
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    print('🚀 Performance Optimization Verification Started');
  }

  // Initialize services
  final cacheService = LogoCacheService.instance;

  // Test cache functionality
  if (kDebugMode) {
    print('📦 Testing LogoCacheService...');
  }
  final startTime = DateTime.now();

  final logo1 = await cacheService.getSuggestedLogo('nike');
  final logo2 = await cacheService.getSuggestedLogo('nike'); // Should be cached

  final cacheTime = DateTime.now().difference(startTime);
  if (kDebugMode) {
    print('✅ Cache test completed in ${cacheTime.inMilliseconds}ms');
  }
  if (kDebugMode) {
    print('✅ Logo suggestion cached: ${logo1 == logo2}');
  }

  // Test logo loading
  if (kDebugMode) {
    print('📋 Testing logo loading...');
  }
  final logoStartTime = DateTime.now();
  final logos = await cacheService.getAllAvailableLogos();
  final logoTime = DateTime.now().difference(logoStartTime);
  if (kDebugMode) {
    print('✅ Loaded ${logos.length} logos in ${logoTime.inMilliseconds}ms');
  }

  // Test cache stats
  final stats = cacheService.getCacheStats();
  if (kDebugMode) {
    print('📊 Cache Statistics:');
  }
  stats.forEach((key, value) {
    if (kDebugMode) {
      print('   $key: $value');
    }
  });

  if (kDebugMode) {
    print('🎉 Performance optimization verification completed!');
  }
  if (kDebugMode) {
    print('✨ Ready to run optimized Flutter app');
  }

  // Run the app
  runApp(const MyApp());
}
