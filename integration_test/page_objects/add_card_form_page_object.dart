import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cards/models/card_item.dart';

/// Page Object for AddCardFormPage
/// Manual form entry with fields for title, description, code, type, and logo selection
class AddCardFormPageObject {
  final WidgetTester tester;

  AddCardFormPageObject(this.tester);

  // ===== Finders =====
  Finder get _titleField => find.byKey(const ValueKey('title_field'));
  Finder get _descriptionField =>
      find.byKey(const ValueKey('description_field'));
  Finder get _codeField => find.byKey(const ValueKey('code_field'));
  Finder get _cardTypeDropdown =>
      find.byKey(const ValueKey('card_type_dropdown'));
  Finder get _logoButton => find.byKey(const ValueKey('select_logo_button'));
  Finder get _submitButton => find.byKey(const ValueKey('submit_button'));
  Finder get _cancelButton => find.byKey(const ValueKey('cancel_button'));
  Finder get _appBar => find.byType(AppBar);
  Finder get _cardPreview => find.byKey(const ValueKey('card_preview'));

  // ===== Verifications =====
  Future<void> verifyAddCardFormPageDisplayed() async {
    expect(_appBar, findsOneWidget, reason: 'AppBar should be visible');
    // Wait briefly for the title field to appear (handles async navigation)
    final found = await TestSyncHelper.waitForFinder(
      tester,
      _titleField,
      timeout: const Duration(seconds: 2),
    );
    expect(found, isTrue, reason: 'Title field should be visible');
    expect(_codeField, findsOneWidget, reason: 'Code field should be visible');
    expect(
      _submitButton,
      findsOneWidget,
      reason: 'Submit button should be visible',
    );
  }

  Future<void> verifyTitleFieldHasText(String text) async {
    final titleWidget = tester.widget<TextField>(_titleField);
    expect(
      titleWidget.controller?.text,
      text,
      reason: 'Title field should contain: $text',
    );
  }

  Future<void> verifyCodeFieldHasText(String text) async {
    final codeWidget = tester.widget<TextField>(_codeField);
    expect(
      codeWidget.controller?.text,
      text,
      reason: 'Code field should contain: $text',
    );
  }

  Future<void> verifySelectedCardType(String expectedType) async {
    final dropdown = tester.widget<DropdownButton<CardType>>(_cardTypeDropdown);
    expect(
      dropdown.value?.displayName,
      expectedType,
      reason: 'Selected card type should be: $expectedType',
    );
  }

  Future<void> verifySubmitButtonEnabled() async {
    final button = tester.widget<ElevatedButton>(_submitButton);
    expect(
      button.onPressed,
      isNotNull,
      reason: 'Submit button should be enabled',
    );
  }

  Future<void> verifySubmitButtonDisabled() async {
    final button = tester.widget<ElevatedButton>(_submitButton);
    expect(
      button.onPressed,
      isNull,
      reason: 'Submit button should be disabled',
    );
  }

  Future<void> verifyCardPreviewVisible() async {
    expect(
      _cardPreview,
      findsOneWidget,
      reason: 'Card preview should be displayed',
    );
  }

  // ===== Actions =====
  Future<void> fillTitleField(String title) async {
    await tester.ensureVisible(_titleField);
    await tester.tap(_titleField);
    await tester.pump();
    await tester.enterText(_titleField, title);
    await tester.pumpAndSettle();
  }

  Future<void> fillDescriptionField(String description) async {
    await tester.ensureVisible(_descriptionField);
    await tester.tap(_descriptionField);
    await tester.pump();
    await tester.enterText(_descriptionField, description);
    await tester.pumpAndSettle();
  }

  Future<void> fillCodeField(String code) async {
    await tester.ensureVisible(_codeField);
    await tester.tap(_codeField);
    await tester.pump();
    await tester.enterText(_codeField, code);
    await tester.pumpAndSettle();
  }

  Future<void> selectCardType(String cardType) async {
    await tester.ensureVisible(_cardTypeDropdown);
    await tester.tap(_cardTypeDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(cardType).last);
    await tester.pumpAndSettle();
  }

  Future<void> tapSelectLogoButton() async {
    await tester.ensureVisible(_logoButton);
    await tester.tap(_logoButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapSubmitButton() async {
    await tester.ensureVisible(_submitButton);
    await tester.tap(_submitButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapCancelButton() async {
    await tester.ensureVisible(_cancelButton);
    await tester.tap(_cancelButton);
    await tester.pumpAndSettle();
  }

  Future<void> fillFullForm({
    required String title,
    String description = '',
    required String code,
    String cardType = 'QR Code',
  }) async {
    await fillTitleField(title);
    if (description.isNotEmpty) {
      await fillDescriptionField(description);
    }
    await fillCodeField(code);
    await selectCardType(cardType);
    await tester.pumpAndSettle();
  }

  Future<void> tapBackButton() async {
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
  }
}
