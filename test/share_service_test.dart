import 'dart:io';

import 'package:cards/models/card_item.dart';
import 'package:cards/services/share_service.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ShareService places image and calls share function', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('root'))),
    );

    final tempDir = await Directory.systemTemp.createTemp('share_test');
    final fakeGetTempDir = () async => tempDir;
    bool shareCalled = false;
    List<String> sharedPaths = [];
    final fakeShare = (List<XFile> files, {String? text}) async {
      shareCalled = true;
      for (final f in files) {
        sharedPaths.add(f.path);
      }
    };

    final service = ShareService(
      getTempDir: fakeGetTempDir,
      shareFiles: fakeShare,
    );

    final card = CardItem(
      id: 999,
      title: 'Test Share',
      description: 'desc',
      name: 'SHARE_ME',
      cardType: CardType.qrCode,
      sortOrder: 0,
    );

    // Act: call share. This will insert an overlay and capture it.
    final shareFuture = service.shareCardAsImage(
      tester.element(find.byType(Scaffold)),
      card,
    );

    // Pump a frame so the overlay can be built and rendered, then allow
    // the share future to complete (with a timeout to keep the test fast).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await shareFuture.timeout(const Duration(seconds: 5));

    // Assert
    expect(shareCalled, isTrue);
    expect(sharedPaths.isNotEmpty, isTrue);

    // Cleanup
    await tempDir.delete(recursive: true);
  });
}
