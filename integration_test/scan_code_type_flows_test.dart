import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:cards/models/card_item.dart';
import 'package:cards/pages/add_card_entry_page.dart';
import 'package:cards/pages/camera_scan_page.dart';
import 'package:cards/pages/card_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'helpers/test_helpers.dart';
import 'page_objects/add_card_entry_page_object.dart';
import 'page_objects/add_card_form_page_object.dart';
import 'page_objects/card_detail_page_object.dart';

void main() {
  final navigatorKey = GlobalKey<NavigatorState>();
  late AddCardEntryPageObject addCardEntryPage;
  late AddCardFormPageObject addCardFormPage;
  late CardDetailPageObject cardDetailPage;

  setUpAll(() async {
    await setupIntegrationTestEnvironment();
  });

  setUp(() {
    CameraScanTestOverrides.clear();
    ScreenshotHelper.reset();
  });

  testWidgets(
    'Given I scan a barcode, when I open the details screen, then the code is a barcode',
    (WidgetTester tester) async {
      addCardEntryPage = AddCardEntryPageObject(tester);
      addCardFormPage = AddCardFormPageObject(tester);
      cardDetailPage = CardDetailPageObject(tester);

      final testData = TestCardDataHelper.getScannedBarcodeData();

      CameraScanTestOverrides.queueResult(
        CameraScanTestResult(
          code: testData['code'] as String,
          format: BarcodeFormat.code128,
        ),
      );

      await tester.pumpWidget(
        IntegrationTestApp(
          navigatorKey: navigatorKey,
          home: _ScanFlowHarness(navigatorKey: navigatorKey),
        ),
      );
      await TestSyncHelper.waitForPageTransition(tester);

      await addCardEntryPage.verifyAddCardEntryPageDisplayed();
      await ScreenshotHelper.capture(tester, 'scan_barcode_01_entry_page');

      await addCardEntryPage.tapScanBarcodeButton();
      await tester.pumpAndSettle();

      await addCardFormPage.verifyAddCardFormPageDisplayed();
      await addCardFormPage.verifyCodeFieldHasText(testData['code'] as String);
      await addCardFormPage.verifySelectedCardType('Barcode');
      await ScreenshotHelper.capture(tester, 'scan_barcode_02_form_prefilled');

      await addCardFormPage.fillTitleField(testData['title'] as String);
      await addCardFormPage.fillDescriptionField(
        testData['description'] as String,
      );
      await addCardFormPage.tapSubmitButton();

      await TestSyncHelper.waitForPageTransition(tester);

      await cardDetailPage.verifyCardDetailPageDisplayed();
      await cardDetailPage.verifyCardTitle(testData['title'] as String);
      await cardDetailPage.verifyCardDescription(
        testData['description'] as String,
      );
      await cardDetailPage.verifyCardType('Barcode');
      expect(find.byType(bw.BarcodeWidget), findsWidgets);
      expect(find.byType(QrImageView), findsNothing);
      await ScreenshotHelper.capture(tester, 'scan_barcode_03_detail_screen');
    },
    timeout: const Timeout(Duration(seconds: 60)),
  );

  testWidgets(
    'Given I scan a qr code, when I open the details screen, then the code is a qr code',
    (WidgetTester tester) async {
      addCardEntryPage = AddCardEntryPageObject(tester);
      addCardFormPage = AddCardFormPageObject(tester);
      cardDetailPage = CardDetailPageObject(tester);

      final testData = TestCardDataHelper.getScannedQrCodeData();

      CameraScanTestOverrides.queueResult(
        CameraScanTestResult(
          code: testData['code'] as String,
          format: BarcodeFormat.qrCode,
        ),
      );

      await tester.pumpWidget(
        IntegrationTestApp(
          navigatorKey: navigatorKey,
          home: _ScanFlowHarness(navigatorKey: navigatorKey),
        ),
      );
      await TestSyncHelper.waitForPageTransition(tester);

      await addCardEntryPage.verifyAddCardEntryPageDisplayed();
      await ScreenshotHelper.capture(tester, 'scan_qrcode_01_entry_page');

      await addCardEntryPage.tapScanBarcodeButton();
      await tester.pumpAndSettle();

      await addCardFormPage.verifyAddCardFormPageDisplayed();
      await addCardFormPage.verifyCodeFieldHasText(testData['code'] as String);
      await addCardFormPage.verifySelectedCardType('QR Code');
      await ScreenshotHelper.capture(tester, 'scan_qrcode_02_form_prefilled');

      await addCardFormPage.fillTitleField(testData['title'] as String);
      await addCardFormPage.fillDescriptionField(
        testData['description'] as String,
      );
      await addCardFormPage.tapSubmitButton();

      await TestSyncHelper.waitForPageTransition(tester);

      await cardDetailPage.verifyCardDetailPageDisplayed();
      await cardDetailPage.verifyCardTitle(testData['title'] as String);
      await cardDetailPage.verifyCardDescription(
        testData['description'] as String,
      );
      await cardDetailPage.verifyCardType('QR Code');
      expect(find.byType(QrImageView), findsWidgets);
      expect(find.byType(bw.BarcodeWidget), findsNothing);
      await ScreenshotHelper.capture(tester, 'scan_qrcode_03_detail_screen');
    },
    timeout: const Timeout(Duration(seconds: 60)),
  );

  testWidgets(
    'Given I scan a barcode for a temporary card, when I open the details screen, then the code is a barcode and the expiry date is shown',
    (WidgetTester tester) async {
      addCardEntryPage = AddCardEntryPageObject(tester);
      addCardFormPage = AddCardFormPageObject(tester);
      cardDetailPage = CardDetailPageObject(tester);

      final testData = TestCardDataHelper.getScannedBarcodeTempData();

      CameraScanTestOverrides.queueResult(
        CameraScanTestResult(
          code: testData['code'] as String,
          format: BarcodeFormat.code128,
        ),
      );

      await tester.pumpWidget(
        IntegrationTestApp(
          navigatorKey: navigatorKey,
          home: _TempScanFlowHarness(navigatorKey: navigatorKey),
        ),
      );
      await TestSyncHelper.waitForPageTransition(tester);

      await addCardEntryPage.verifyAddCardEntryPageDisplayed();
      await ScreenshotHelper.capture(tester, 'scan_temp_barcode_01_entry_page');

      await addCardEntryPage.tapScanBarcodeButton();
      await tester.pumpAndSettle();

      await addCardFormPage.verifyAddCardFormPageDisplayed();
      await addCardFormPage.verifyCodeFieldHasText(testData['code'] as String);
      await addCardFormPage.verifySelectedCardType('Barcode');
      await ScreenshotHelper.capture(
        tester,
        'scan_temp_barcode_02_form_prefilled',
      );

      await addCardFormPage.fillTitleField(testData['title'] as String);
      await addCardFormPage.fillDescriptionField(
        testData['description'] as String,
      );
      await addCardFormPage.tapSubmitButton();

      await TestSyncHelper.waitForPageTransition(tester);

      await cardDetailPage.verifyCardDetailPageDisplayed();
      await cardDetailPage.verifyCardTitle(testData['title'] as String);
      await cardDetailPage.verifyCardType('Barcode');
      await cardDetailPage.verifyExpiryDateVisible();
      expect(find.byType(bw.BarcodeWidget), findsWidgets);
      expect(find.byType(QrImageView), findsNothing);
      await ScreenshotHelper.capture(
        tester,
        'scan_temp_barcode_03_detail_screen',
      );
    },
    timeout: const Timeout(Duration(seconds: 60)),
  );

  testWidgets(
    'Given I scan a qr code for a temporary card, when I open the details screen, then the code is a qr code and the expiry date is shown',
    (WidgetTester tester) async {
      addCardEntryPage = AddCardEntryPageObject(tester);
      addCardFormPage = AddCardFormPageObject(tester);
      cardDetailPage = CardDetailPageObject(tester);

      final testData = TestCardDataHelper.getScannedQrCodeTempData();

      CameraScanTestOverrides.queueResult(
        CameraScanTestResult(
          code: testData['code'] as String,
          format: BarcodeFormat.qrCode,
        ),
      );

      await tester.pumpWidget(
        IntegrationTestApp(
          navigatorKey: navigatorKey,
          home: _TempScanFlowHarness(navigatorKey: navigatorKey),
        ),
      );
      await TestSyncHelper.waitForPageTransition(tester);

      await addCardEntryPage.verifyAddCardEntryPageDisplayed();
      await ScreenshotHelper.capture(tester, 'scan_temp_qrcode_01_entry_page');

      await addCardEntryPage.tapScanBarcodeButton();
      await tester.pumpAndSettle();

      await addCardFormPage.verifyAddCardFormPageDisplayed();
      await addCardFormPage.verifyCodeFieldHasText(testData['code'] as String);
      await addCardFormPage.verifySelectedCardType('QR Code');
      await ScreenshotHelper.capture(
        tester,
        'scan_temp_qrcode_02_form_prefilled',
      );

      await addCardFormPage.fillTitleField(testData['title'] as String);
      await addCardFormPage.fillDescriptionField(
        testData['description'] as String,
      );
      await addCardFormPage.tapSubmitButton();

      await TestSyncHelper.waitForPageTransition(tester);

      await cardDetailPage.verifyCardDetailPageDisplayed();
      await cardDetailPage.verifyCardTitle(testData['title'] as String);
      await cardDetailPage.verifyCardType('QR Code');
      await cardDetailPage.verifyExpiryDateVisible();
      expect(find.byType(QrImageView), findsWidgets);
      expect(find.byType(bw.BarcodeWidget), findsNothing);
      await ScreenshotHelper.capture(
        tester,
        'scan_temp_qrcode_03_detail_screen',
      );
    },
    timeout: const Timeout(Duration(seconds: 60)),
  );
}

class _ScanFlowHarness extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const _ScanFlowHarness({required this.navigatorKey});

  void _openDetails(CardItem card) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => CardDetailPage(card: card)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AddCardEntryPage(onCardCreated: _openDetails);
  }
}

/// Same harness but stamps a 7-day expiry onto the card before opening details,
/// simulating a card created with the "temporary" preset in the bottom sheet.
class _TempScanFlowHarness extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const _TempScanFlowHarness({required this.navigatorKey});

  void _openDetails(CardItem card) {
    final tempCard = card.copyWith(
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => CardDetailPage(card: tempCard)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AddCardEntryPage(onCardCreated: _openDetails);
  }
}
