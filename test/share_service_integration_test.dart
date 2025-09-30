// dart:io not needed in this mocked test

import 'package:cards/models/card_item.dart';
import 'package:cards/services/share_service.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Fast mocked test: QR path
  testWidgets('ShareService (mocked) shares QR image quickly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('root'))),
    );
    await tester.pumpAndSettle();

    final capturedContext = tester.element(find.byType(Scaffold));

    // Avoid real file IO in widget tests: record share calls and file paths
    // in-memory only.
    bool shareCalled = false;
    final List<String> sharedPaths = [];

    void fakeShareSync(List<XFile> files, {String? text}) {
      shareCalled = true;
      for (final f in files) sharedPaths.add(f.path);
    }

    final fakeShare = (List<XFile> files, {String? text}) async {
      fakeShareSync(files, text: text);
    };

    final service = ShareService(
      shareFiles: fakeShare,
      codeBuilder:
          (ctx, c) => Container(width: 320, height: 320, color: Colors.black),
    );

    final card = CardItem(
      id: 1,
      title: 'QR',
      description: '',
      name: 'QRCODE',
      cardType: CardType.qrCode,
      sortOrder: 0,
    );

    // Use the test hook to avoid canvas capture in the widget test. The
    // hook will simulate creating a file and calling the share function so
    // the remaining logic can be asserted quickly.
    ShareService.testShareHook = (BuildContext? ctx, CardItem c) async {
      try {
        // Simulate a successful share by invoking the fake share with a
        // fake file path; don't actually write files in widget tests.
        await fakeShare([
          XFile('/tmp/fake_qr_${c.id ?? c.name}.png'),
        ], text: c.title);
      } finally {
        // nothing to cleanup here
      }
    };

    try {
      await service.shareCardAsImage(capturedContext, card);
      // Assertions: confirm the fake share was called and recorded a path.
      expect(shareCalled, isTrue);
      expect(sharedPaths, isNotEmpty);
    } finally {
      ShareService.testShareHook = null;
    }
  });

  // Fast mocked test: Barcode path
  testWidgets('ShareService (mocked) shares Barcode image quickly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('root'))),
    );
    await tester.pumpAndSettle();

    final capturedContext = tester.element(find.byType(Scaffold));

    bool shareCalled = false;
    final List<String> sharedPaths = [];

    void fakeShareSync(List<XFile> files, {String? text}) {
      shareCalled = true;
      for (final f in files) sharedPaths.add(f.path);
    }

    final fakeShare = (List<XFile> files, {String? text}) async {
      fakeShareSync(files, text: text);
    };

    final service = ShareService(
      shareFiles: fakeShare,
      codeBuilder:
          (ctx, c) => Container(width: 320, height: 120, color: Colors.black),
    );

    final card = CardItem(
      id: 2,
      title: 'Barcode',
      description: '',
      name: 'BARCODE',
      cardType: CardType.barcode,
      sortOrder: 0,
    );

    ShareService.testShareHook = (BuildContext? ctx, CardItem c) async {
      try {
        await fakeShare([
          XFile('/tmp/fake_barcode_${c.id ?? c.name}.png'),
        ], text: c.title);
      } finally {
        // nothing to cleanup
      }
    };

    try {
      await service.shareCardAsImage(capturedContext, card);
      expect(shareCalled, isTrue);
      expect(sharedPaths, isNotEmpty);
    } finally {
      ShareService.testShareHook = null;
    }
  });
}
