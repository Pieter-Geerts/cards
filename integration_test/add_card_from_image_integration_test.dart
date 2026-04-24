import 'package:cards/config/app_localization.dart';
import 'package:cards/helpers/image_scan_helper.dart';
import 'package:cards/models/card_item.dart';
import 'package:cards/widgets/add_card_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Add card from image flow adds card to homepage', (
    WidgetTester tester,
  ) async {
    // For determinism in CI, pump the AddCardBottomSheet directly inside a
    // MaterialApp and drive the flow. We use the test hook on
    // ImageScanHelper to return a deterministic scan result.
    ImageScanHelper.testScanResult = {
      'code': 'TEST_CARD_CODE',
      'type': CardType.qrCode,
      'imagePath': '/tmp/fake_image.jpg',
      'hasAutoDetection': true,
    };

    CardItem? createdCard;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizationConfig.localizationsDelegates,
        supportedLocales: AppLocalizationConfig.supportedLocales,
        home: Scaffold(
          body: AddCardBottomSheet(
            onCardCreated: (card) {
              createdCard = card;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Select generic card option
    final genericCardOption = find.byKey(const ValueKey('generic_card_option'));
    expect(genericCardOption, findsOneWidget);
    await tester.tap(genericCardOption);
    await tester.pumpAndSettle();

    // Move to details step (title field)
    final nextButton = find.byKey(const ValueKey('next_button'));
    expect(nextButton, findsOneWidget);
    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    // Fill in required title
    final titleField = find.byKey(const ValueKey('card_title_field'));
    expect(titleField, findsOneWidget);
    await tester.enterText(titleField, 'Test Card');
    await tester.pumpAndSettle();

    // Advance to code acquisition
    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    // Import from image (uses testScanResult)
    // Proceed to find import option in UI

    var importFromImage = find.byKey(
      const ValueKey('import_from_image_option'),
    );
    if (!tester.any(importFromImage)) {
      importFromImage = find.byIcon(Icons.photo_library_outlined);
    }
    if (!tester.any(importFromImage)) {
      importFromImage = find.textContaining('Import');
    }
    expect(importFromImage, findsOneWidget);
    await tester.tap(importFromImage);
    await tester.pumpAndSettle();

    // Select the 'Select Image' option in the dialog
    final selectImageButton = find.text('Select Image');
    if (tester.any(selectImageButton)) {
      await tester.tap(selectImageButton);
      await tester.pumpAndSettle();
    }

    // Now save the card
    final saveButton = find.byKey(const ValueKey('save_card_button'));
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Confirm the onCardCreated callback was invoked
    expect(createdCard, isNotNull);
    expect(createdCard!.name, equals('TEST_CARD_CODE'));
  });
}
