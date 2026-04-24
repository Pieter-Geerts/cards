import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Page Object for CameraScanPage
/// Camera-based barcode/QR code scanning with flash control
class CameraScanPageObject {
  final WidgetTester tester;

  CameraScanPageObject(this.tester);

  // ===== Finders =====
  Finder get _cameraPreview => find.byKey(const ValueKey('camera_preview'));
  Finder get _flashButton => find.byKey(const ValueKey('flash_toggle_button'));
  Finder get _appBar => find.byType(AppBar);

  // ===== Verifications =====
  Future<void> verifyCameraScanPageDisplayed() async {
    expect(_appBar, findsOneWidget, reason: 'AppBar should be visible');
    expect(
      _cameraPreview,
      findsOneWidget,
      reason: 'Camera preview should be visible',
    );
    expect(
      _flashButton,
      findsOneWidget,
      reason: 'Flash button should be visible',
    );
  }

  Future<void> verifyFlashButtonVisible() async {
    expect(_flashButton, findsOneWidget, reason: 'Flash button should exist');
  }

  // ===== Actions =====
  Future<void> tapFlashButton() async {
    await tester.tap(_flashButton);
    await tester.pump();
  }

  Future<void> tapCloseButton() async {
    await tapBackButton();
  }

  Future<void> tapBackButton() async {
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
  }
}
