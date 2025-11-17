import 'package:cards/services/logo_cache_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cards/utils/simple_icons_mapping.dart';

void main() {
  group('LogoCacheService whitelist configuration', () {
    final service = LogoCacheService.instance;

    setUp(() {
      service.clearCache();
      // Reset to default (via setter)
      service.setShopWhitelist({
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
      });
    });

    tearDown(() {
      service.clearCache();
    });

    test('getShopWhitelist returns a copy', () {
      final w1 = service.getShopWhitelist();
      final w2 = service.getShopWhitelist();
      expect(w1, equals(w2));
      expect(identical(w1, w2), isFalse);
    });

    test('setShopWhitelist replaces list and invalidates cache', () async {
      // Start with a small custom whitelist
      service.setShopWhitelist({'amazon', 'ikea'});
      expect(service.getShopWhitelist().contains('amazon'), isTrue);

      final logos = await service.getAllAvailableLogos();
      // All logos returned should be in the allowed set
      for (final icon in logos) {
        final id = SimpleIconsMapping.getIdentifier(icon);
        expect(id, isNotNull);
        final name = id!.substring('simple_icon:'.length);
        expect({'amazon', 'ikea'}.contains(name), isTrue);
      }
    });

    test('addShopToWhitelist and removeShopFromWhitelist work', () async {
      service.setShopWhitelist({'nike'});
      var logos = await service.getAllAvailableLogos();
      expect(logos.isNotEmpty, isTrue);

      // Add 'amazon'
      service.addShopToWhitelist('amazon');
      logos = await service.getAllAvailableLogos();
      // Now we should see amazon or still nike, but at least both allowed
      final ids =
          logos
              .map((e) => SimpleIconsMapping.getIdentifier(e))
              .whereType<String>()
              .map((s) => s.substring('simple_icon:'.length))
              .toSet();
      expect(ids.contains('amazon') || ids.contains('nike'), isTrue);

      // Remove nike
      service.removeShopFromWhitelist('nike');
      logos = await service.getAllAvailableLogos();
      final ids2 =
          logos
              .map((e) => SimpleIconsMapping.getIdentifier(e))
              .whereType<String>()
              .map((s) => s.substring('simple_icon:'.length))
              .toSet();
      expect(ids2.contains('nike'), isFalse);
    });
  });
}
