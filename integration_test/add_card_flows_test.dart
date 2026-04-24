import 'package:cards/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_helpers.dart';
import 'page_objects/add_card_entry_page_object.dart';
import 'page_objects/add_card_form_page_object.dart';
import 'page_objects/card_detail_page_object.dart';
import 'page_objects/home_page_object.dart';
import 'page_objects/logo_selection_page_object.dart';

void main() {
  late HomePageObject homePage;
  late AddCardEntryPageObject addCardEntryPage;
  late AddCardFormPageObject addCardFormPage;
  late LogoSelectionPageObject logoSelectionPage;
  late CardDetailPageObject cardDetailPage;

  setUpAll(() async {
    await setupIntegrationTestEnvironment();
  });

  group('Add Card Flow E2E Tests', () {
    testWidgets(
      'Complete manual add card flow - QR Code with logo selection',
      (WidgetTester tester) async {
        // Initialize page objects with this test's tester
        homePage = HomePageObject(tester);
        addCardEntryPage = AddCardEntryPageObject(tester);
        addCardFormPage = AddCardFormPageObject(tester);
        logoSelectionPage = LogoSelectionPageObject(tester);
        cardDetailPage = CardDetailPageObject(tester);

        // ===== Arrange: Start app =====
        await tester.pumpWidget(const MyApp());
        await TestSyncHelper.waitForPageTransition(tester);

        // ===== Act & Assert: Verify home page loaded =====
        await homePage.verifyHomePageDisplayed();
        await homePage.verifyAddCardFABVisible();

        // ===== Act: Tap FAB to start add card flow =====
        await homePage.tapAddCardFAB();

        // ===== Assert: Add card entry page shown =====
        await addCardEntryPage.verifyAddCardEntryPageDisplayed();
        await addCardEntryPage.verifyAllOptionsAvailable();

        // ===== Act: Select manual entry =====
        await addCardEntryPage.tapManualEntryButton();

        // ===== Assert: Add card form displayed =====
        await addCardFormPage.verifyAddCardFormPageDisplayed();

        // ===== Act: Fill form with QR code data =====
        final testData = TestCardDataHelper.getValidQRCodeData();
        await addCardFormPage.fillTitleField(testData['title']);
        await addCardFormPage.fillDescriptionField(testData['description']);
        await addCardFormPage.fillCodeField(testData['code']);
        await addCardFormPage.selectCardType(testData['type']);

        // ===== Assert: Form fields populated correctly =====
        await addCardFormPage.verifyTitleFieldHasText(testData['title']);
        await addCardFormPage.verifyCodeFieldHasText(testData['code']);
        await addCardFormPage.verifySubmitButtonEnabled();

        // ===== Act: Select logo =====
        await addCardFormPage.tapSelectLogoButton();

        // ===== Assert: Logo selection page displayed =====
        await logoSelectionPage.verifyLogoSelectionPageDisplayed();
        await logoSelectionPage.verifyLogosDisplayed();

        // ===== Act: Search for a logo and select it =====
        await logoSelectionPage.searchForLogo('amazon');
        await logoSelectionPage.selectLogoByIndex(0);

        // ===== Act: Confirm logo selection =====
        await logoSelectionPage.tapConfirmButton();

        // ===== Assert: Form page shown again =====
        await addCardFormPage.verifyAddCardFormPageDisplayed();

        // ===== Act: Submit form to create card =====
        await addCardFormPage.tapSubmitButton();

        // ===== Assert: Return to home page =====
        await TestSyncHelper.waitForPageTransition(tester);
        await homePage.verifyHomePageDisplayed();

        // ===== Assert: New card is visible in list =====
        await homePage.verifyCardVisible(testData['title']);
      },
      timeout: const Timeout(Duration(seconds: 60)),
    );

    testWidgets(
      'Add card flow - Barcode type selection',
      (WidgetTester tester) async {
        homePage = HomePageObject(tester);
        addCardEntryPage = AddCardEntryPageObject(tester);
        addCardFormPage = AddCardFormPageObject(tester);

        await tester.pumpWidget(const MyApp());
        await TestSyncHelper.waitForPageTransition(tester);

        await homePage.verifyHomePageDisplayed();
        await homePage.tapAddCardFAB();

        await addCardEntryPage.verifyAddCardEntryPageDisplayed();
        await addCardEntryPage.tapManualEntryButton();

        await addCardFormPage.verifyAddCardFormPageDisplayed();

        // ===== Act: Fill with barcode data =====
        final testData = TestCardDataHelper.getValidBarcodeData();
        await addCardFormPage.fillTitleField(testData['title']);
        await addCardFormPage.fillCodeField(testData['code']);
        await addCardFormPage.selectCardType(testData['type']);

        // ===== Assert: Form correctly configured for barcode =====
        await addCardFormPage.verifySubmitButtonEnabled();

        await addCardFormPage.tapSubmitButton();

        await TestSyncHelper.waitForPageTransition(tester);

        // ===== Assert: Card created with barcode type =====
        await homePage.verifyCardVisible(testData['title']);
      },
      timeout: const Timeout(Duration(seconds: 60)),
    );

    testWidgets(
      'Add card flow - Cancel at entry page',
      (WidgetTester tester) async {
        homePage = HomePageObject(tester);
        addCardEntryPage = AddCardEntryPageObject(tester);

        await tester.pumpWidget(const MyApp());
        await TestSyncHelper.waitForPageTransition(tester);

        await homePage.verifyHomePageDisplayed();
        await homePage.tapAddCardFAB();

        await addCardEntryPage.verifyAddCardEntryPageDisplayed();

        // ===== Act: Cancel by going back =====
        await addCardEntryPage.tapBackButton();

        // ===== Assert: Return to home without creating card =====
        await homePage.verifyHomePageDisplayed();
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    testWidgets(
      'Add card flow - Cancel at form page',
      (WidgetTester tester) async {
        homePage = HomePageObject(tester);
        addCardEntryPage = AddCardEntryPageObject(tester);
        addCardFormPage = AddCardFormPageObject(tester);

        await tester.pumpWidget(const MyApp());
        await TestSyncHelper.waitForPageTransition(tester);

        await homePage.verifyHomePageDisplayed();
        await homePage.tapAddCardFAB();

        await addCardEntryPage.verifyAddCardEntryPageDisplayed();
        await addCardEntryPage.tapManualEntryButton();

        await addCardFormPage.verifyAddCardFormPageDisplayed();

        // ===== Act: Cancel mid-form =====
        await addCardFormPage.tapCancelButton();

        // ===== Assert: Return to home =====
        await TestSyncHelper.waitForPageTransition(tester);
        await homePage.verifyHomePageDisplayed();
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    testWidgets(
      'Add card flow - Multiple cards added sequentially',
      (WidgetTester tester) async {
        homePage = HomePageObject(tester);
        addCardEntryPage = AddCardEntryPageObject(tester);
        addCardFormPage = AddCardFormPageObject(tester);

        await tester.pumpWidget(const MyApp());
        await TestSyncHelper.waitForPageTransition(tester);

        // ===== Create First Card =====
        await homePage.verifyHomePageDisplayed();
        await homePage.tapAddCardFAB();

        await addCardEntryPage.verifyAddCardEntryPageDisplayed();
        await addCardEntryPage.tapManualEntryButton();

        final card1Data = TestCardDataHelper.getValidQRCodeData();
        await addCardFormPage.fillFullForm(
          title: card1Data['title'],
          description: card1Data['description'],
          code: card1Data['code'],
          cardType: card1Data['type'],
        );
        await addCardFormPage.tapSubmitButton();

        await TestSyncHelper.waitForPageTransition(tester);
        await homePage.verifyCardVisible(card1Data['title']);

        // ===== Create Second Card =====
        await homePage.tapAddCardFAB();

        await addCardEntryPage.verifyAddCardEntryPageDisplayed();
        await addCardEntryPage.tapManualEntryButton();

        final card2Data = TestCardDataHelper.getValidCustomCardData(
          title: 'Second Card',
          code: '1111111111111',
        );
        await addCardFormPage.fillFullForm(
          title: card2Data['title'],
          code: card2Data['code'],
          cardType: card2Data['type'],
        );
        await addCardFormPage.tapSubmitButton();

        await TestSyncHelper.waitForPageTransition(tester);

        // ===== Assert: Both cards visible =====
        await homePage.verifyCardVisible(card1Data['title']);
        await homePage.verifyCardVisible(card2Data['title']);
      },
      timeout: const Timeout(Duration(seconds: 90)),
    );

    testWidgets(
      'Add card flow - Verify card details after creation',
      (WidgetTester tester) async {
        homePage = HomePageObject(tester);
        addCardEntryPage = AddCardEntryPageObject(tester);
        addCardFormPage = AddCardFormPageObject(tester);
        cardDetailPage = CardDetailPageObject(tester);

        await tester.pumpWidget(const MyApp());
        await TestSyncHelper.waitForPageTransition(tester);

        await homePage.verifyHomePageDisplayed();
        await homePage.tapAddCardFAB();

        await addCardEntryPage.verifyAddCardEntryPageDisplayed();
        await addCardEntryPage.tapManualEntryButton();

        final testData = TestCardDataHelper.getValidQRCodeData();
        await addCardFormPage.fillTitleField(testData['title']);
        await addCardFormPage.fillDescriptionField(testData['description']);
        await addCardFormPage.fillCodeField(testData['code']);
        await addCardFormPage.selectCardType(testData['type']);
        await addCardFormPage.tapSubmitButton();

        await TestSyncHelper.waitForPageTransition(tester);

        // ===== Act: Open created card =====
        await homePage.tapCardByTitle(testData['title']);

        // ===== Assert: Card details match input =====
        await cardDetailPage.verifyCardDetailPageDisplayed();
        await cardDetailPage.verifyCardTitle(testData['title']);
        await cardDetailPage.verifyCardDescription(testData['description']);
        await cardDetailPage.verifyCodeVisible();
        await cardDetailPage.verifyActionButtonsVisible();
      },
      timeout: const Timeout(Duration(seconds: 60)),
    );

    testWidgets(
      'Add card flow - Form validation (empty required fields)',
      (WidgetTester tester) async {
        homePage = HomePageObject(tester);
        addCardEntryPage = AddCardEntryPageObject(tester);
        addCardFormPage = AddCardFormPageObject(tester);

        await tester.pumpWidget(const MyApp());
        await TestSyncHelper.waitForPageTransition(tester);

        await homePage.verifyHomePageDisplayed();
        await homePage.tapAddCardFAB();

        await addCardEntryPage.verifyAddCardEntryPageDisplayed();
        await addCardEntryPage.tapManualEntryButton();

        // ===== Assert: Submit button disabled initially =====
        await addCardFormPage.verifyAddCardFormPageDisplayed();
        await addCardFormPage.verifySubmitButtonDisabled();

        // ===== Act: Fill only title =====
        await addCardFormPage.fillTitleField('Only Title');

        // ===== Assert: Submit button still disabled (code required) =====
        await addCardFormPage.verifySubmitButtonDisabled();

        // ===== Act: Fill code field =====
        await addCardFormPage.fillCodeField('TEST123');

        // ===== Assert: Submit button now enabled =====
        await addCardFormPage.verifySubmitButtonEnabled();
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    testWidgets(
      'Add card flow - Logo selection cancel returns to form',
      (WidgetTester tester) async {
        homePage = HomePageObject(tester);
        addCardEntryPage = AddCardEntryPageObject(tester);
        addCardFormPage = AddCardFormPageObject(tester);
        logoSelectionPage = LogoSelectionPageObject(tester);

        await tester.pumpWidget(const MyApp());
        await TestSyncHelper.waitForPageTransition(tester);

        await homePage.verifyHomePageDisplayed();
        await homePage.tapAddCardFAB();

        await addCardEntryPage.verifyAddCardEntryPageDisplayed();
        await addCardEntryPage.tapManualEntryButton();

        await addCardFormPage.verifyAddCardFormPageDisplayed();
        await addCardFormPage.fillFullForm(title: 'Test Card', code: 'TEST123');

        // ===== Act: Open logo selection =====
        await addCardFormPage.tapSelectLogoButton();

        // ===== Assert: Logo page shown =====
        await logoSelectionPage.verifyLogoSelectionPageDisplayed();

        // ===== Act: Cancel logo selection =====
        await logoSelectionPage.tapBackButton();

        // ===== Assert: Return to form page =====
        await addCardFormPage.verifyAddCardFormPageDisplayed();

        // ===== Assert: Form data still intact =====
        await addCardFormPage.verifyTitleFieldHasText('Test Card');
        await addCardFormPage.verifyCodeFieldHasText('TEST123');
      },
      timeout: const Timeout(Duration(seconds: 45)),
    );

    testWidgets(
      'Add card flow - Special characters in title and description',
      (WidgetTester tester) async {
        homePage = HomePageObject(tester);
        addCardEntryPage = AddCardEntryPageObject(tester);
        addCardFormPage = AddCardFormPageObject(tester);
        cardDetailPage = CardDetailPageObject(tester);

        await tester.pumpWidget(const MyApp());
        await TestSyncHelper.waitForPageTransition(tester);

        await homePage.verifyHomePageDisplayed();
        await homePage.tapAddCardFAB();

        await addCardEntryPage.verifyAddCardEntryPageDisplayed();
        await addCardEntryPage.tapManualEntryButton();

        // ===== Act: Fill with special characters =====
        final specialTitle = 'My Card & Co. (2024)';
        final specialDescription = 'Test: Description™ with special chars!';
        final specialCode = 'ABC-123_DEF.456';

        await addCardFormPage.fillTitleField(specialTitle);
        await addCardFormPage.fillDescriptionField(specialDescription);
        await addCardFormPage.fillCodeField(specialCode);
        await addCardFormPage.tapSubmitButton();

        await TestSyncHelper.waitForPageTransition(tester);

        // ===== Assert: Card created with special chars =====
        await homePage.verifyCardVisible(specialTitle);

        // ===== Assert: Details preserved =====
        await homePage.tapCardByTitle(specialTitle);
        await cardDetailPage.verifyCardDetailPageDisplayed();
        await cardDetailPage.verifyCardTitle(specialTitle);
        await cardDetailPage.verifyCardDescription(specialDescription);
      },
      timeout: const Timeout(Duration(seconds: 60)),
    );
  });
}

/// Helper extension for easier widget finding
extension WidgetTesterX on WidgetTester {
  /// Scroll to a specific position
  Future<void> scrollToPosition(
    Finder finder,
    double offset, {
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    final gesture = await startGesture(const Offset(500, 300));
    await gesture.moveBy(Offset(0, offset));
    await pumpAndSettle(duration);
    await gesture.up();
  }
}

// Helper to check if FAB exists (added for clarity in test readability)
extension HomePageObjectHelper on HomePageObject {
  Future<void> verifyAddCardFABVisible() async {
    expect(find.byType(FloatingActionButton), findsOneWidget);
  }
}
