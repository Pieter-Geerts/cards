import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Page Object for AddCardEntryPage
/// Entry point for add card flow with three options: camera, image, or manual
class AddCardEntryPageObject {
  final WidgetTester tester;

  AddCardEntryPageObject(this.tester);

  // ===== Finders =====
  Finder get _scanBarcodeButton =>
      find.byKey(const ValueKey('scan_barcode_button'));
  Finder get _scanFromPhotoButton =>
      find.byKey(const ValueKey('scan_from_photo_button'));
  Finder get _manualEntryButton =>
      find.byKey(const ValueKey('manual_entry_button'));
  Finder get _appBar => find.byType(AppBar);

  // ===== Verifications =====
  Future<void> verifyAddCardEntryPageDisplayed() async {
    expect(_appBar, findsOneWidget, reason: 'AppBar should be visible');
    expect(
      _scanBarcodeButton,
      findsOneWidget,
      reason: 'Scan barcode button should be visible',
    );
  }

  Future<void> verifyAllOptionsAvailable() async {
    expect(
      _scanBarcodeButton,
      findsOneWidget,
      reason: 'Scan barcode option should be available',
    );
    expect(
      _scanFromPhotoButton,
      findsOneWidget,
      reason: 'Scan from photo option should be available',
    );
    expect(
      _manualEntryButton,
      findsOneWidget,
      reason: 'Manual entry option should be available',
    );
  }

  // ===== Actions =====
  Future<void> tapScanBarcodeButton() async {
    await tester.tap(_scanBarcodeButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapScanFromPhotoButton() async {
    await tester.tap(_scanFromPhotoButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapManualEntryButton() async {
    await tester.tap(_manualEntryButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapBackButton() async {
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
  }
}
