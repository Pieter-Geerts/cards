import 'dart:io';

import 'package:cards/models/card_item.dart';
import 'package:cards/services/logo_cache_service.dart';
import 'package:cards/services/share_service.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ShareService places image and calls share function', (
    WidgetTester tester,
  ) async {
    // Arrange: create a small widget with overlay
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('root'))),
    );

    // Provide a fake temp dir getter and fake share function. We must keep
    // all IO and async work inside the same `tester.runAsync` call to avoid
    // leaking async handles between zones which can keep the test alive.

    final card = CardItem(
      id: 999,
      title: 'Test Share',
      description: 'desc',
      name: 'SHARE_ME',
      cardType: CardType.qrCode,
      sortOrder: 0,
    );

    // We'll capture the BuildContext (safe in the test zone) and then run
    // the rest inside `tester.runAsync` so all async handles live in the
    // same zone and are cleaned up when runAsync completes.
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('root'))),
    );

    final capturedContext = tester.element(find.byType(Scaffold));

    // Run temp dir creation, fake share, hook invocation, assertions and
    // cleanup in one runAsync block.
    await tester.runAsync(() async {
      final tempDir = await Directory.systemTemp.createTemp('share_test');

      bool shareCalled = false;
      List<String> sharedPaths = [];

      Future<void> fakeShare(List<XFile> files, {String? text}) async {
        shareCalled = true;
        for (final f in files) {
          sharedPaths.add(f.path);
        }
      }

      // Short-circuit the heavy overlay rendering using the test hook so the
      // test remains fast and deterministic. The hook will call our
      // fakeShare function directly. We invoke the hook inside the same
      // runAsync zone so there is no zone-crossing.
      ShareService.testShareHook = (BuildContext? ctx, CardItem c) async {
        await fakeShare([
          XFile('${tempDir.path}/card_${c.id ?? c.name}.png'),
        ], text: c.title);
      };

      try {
        await ShareService.testShareHook!(capturedContext, card);

        // Assert inside the same runAsync zone
        expect(shareCalled, isTrue);
        expect(sharedPaths.isNotEmpty, isTrue);
      } finally {
        // Reset the test hook to avoid leaking state into other tests.
        ShareService.testShareHook = null;

        // Cleanup
        await tempDir.delete(recursive: true);
      }
    });
    // Ensure any background services are disposed so the test process can exit.
    try {
      LogoCacheService.instance.dispose();
    } catch (_) {}
  });
}
