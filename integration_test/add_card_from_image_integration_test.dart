import 'package:cards/config/app_localization.dart';
import 'package:cards/helpers/image_scan_helper.dart';
import 'package:cards/models/card_item.dart';
import 'package:cards/pages/add_card_entry_page.dart';
import 'package:cards/pages/image_scan_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Add card from image flow opens the canonical card form', (
    WidgetTester tester,
  ) async {
    ImageScanHelper.testScanResult = {
      'imagePath': '/tmp/fake_image.jpg',
      'hasAutoDetection': false,
    };
    ImageScanTestOverrides.queueResults(const [
      DetectedImageCode(
        code: 'TEST_CARD_CODE',
        type: CardType.qrCode,
        format: CodeFormat.qrCode,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizationConfig.localizationsDelegates,
        supportedLocales: AppLocalizationConfig.supportedLocales,
        home: const AddCardEntryPage(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('scan_from_photo_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('image_code_field')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('image_save_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('card_title_field')), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('card_title_field')),
      'Test Card',
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('save_card_button')), findsOneWidget);
  });
}
