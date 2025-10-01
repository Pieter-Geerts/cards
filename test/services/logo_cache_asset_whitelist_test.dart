import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cards/services/logo_cache_service.dart';

void main() {
  testWidgets('loads whitelist from build-config.yaml via injected AssetBundle', (
    WidgetTester tester,
  ) async {
    // Ensure Flutter binding is initialized so rootBundle and asset loading works
    TestWidgetsFlutterBinding.ensureInitialized();

    // Provide mock initial values for SharedPreferences so the plugin
    // doesn't attempt to talk to platform channels during tests.
    SharedPreferences.setMockInitialValues({});

    // Create a fake asset bundle with a simple YAML containing logo_whitelist
    final yaml = '''
logo_whitelist:
  - shopone
  - shoptwo
''';

    final bundle = _FakeAssetBundle({'build-config.yaml': yaml});

    // Inject the fake bundle and force reload
    LogoCacheService.instance.setAssetBundleForTesting(bundle);
    await LogoCacheService.instance.reloadWhitelistFromAssets();

    final wl = LogoCacheService.instance.getShopWhitelist();
    expect(wl.contains('shopone'), isTrue);
    expect(wl.contains('shoptwo'), isTrue);
  });
}

class _FakeAssetBundle extends CachingAssetBundle {
  final Map<String, String> _assets;

  _FakeAssetBundle(this._assets);

  @override
  Future<ByteData> load(String key) async {
    final data = _assets[key];
    if (data == null) throw FlutterError('Asset not found: $key');
    final bytes = utf8.encode(data);
    final buffer = Uint8List.fromList(bytes).buffer;
    return ByteData.view(buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final data = _assets[key];
    if (data == null) throw FlutterError('Asset not found: $key');
    return data;
  }
}
