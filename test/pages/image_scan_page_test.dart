import 'package:cards/l10n/app_localizations.dart';
import 'package:cards/models/card_item.dart';
import 'package:cards/pages/image_scan_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(ImageScanTestOverrides.clear);

  testWidgets('allows choosing between multiple detected image codes', (
    tester,
  ) async {
    ImageScanTestOverrides.queueResults(const [
      DetectedImageCode(
        code: '4006381333931',
        type: CardType.barcode,
        format: CodeFormat.ean13,
      ),
      DetectedImageCode(
        code: 'https://example.com',
        type: CardType.qrCode,
        format: CodeFormat.qrCode,
      ),
    ]);

    (String, CardType, CodeFormat)? savedResult;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ImageScanPage(
          imagePath: 'unused-in-test',
          showImagePreview: false,
          onCodeEntered: (code, type, format) {
            savedResult = (code, type, format);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('image_detected_code_selector')),
      findsOneWidget,
    );
    expect(find.text('4006381333931'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('image_detected_code_selector')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('https://example.com (QR Code)').last);
    await tester.pumpAndSettle();

    final codeField = tester.widget<TextField>(
      find.byKey(const ValueKey('image_code_field')),
    );
    expect(codeField.controller?.text, 'https://example.com');

    await tester.tap(find.byKey(const ValueKey('image_save_button')));
    await tester.pumpAndSettle();

    expect(savedResult, (
      'https://example.com',
      CardType.qrCode,
      CodeFormat.qrCode,
    ));
  });
}
