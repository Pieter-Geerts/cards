import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Page Object for CardDetailPage
/// Displays full card information with actions (edit, share, delete)
class CardDetailPageObject {
  final WidgetTester tester;

  CardDetailPageObject(this.tester);

  // ===== Finders =====
  Finder get _appBar => find.byType(AppBar);
  Finder get _codeDisplay => find.byKey(const ValueKey('code_display'));
  Finder get _cardTypeChip => find.byKey(const ValueKey('card_type_chip'));
  Finder get _expiryChip => find.byKey(const ValueKey('expiry_chip'));
  Finder get _editButton => find.byIcon(Icons.edit);
  Finder get _shareButton => find.byIcon(Icons.share);
  Finder get _deleteButton => find.byIcon(Icons.delete);
  Finder get _copyButton => find.byIcon(Icons.copy);
  Finder get _logoDisplay => find.byKey(const ValueKey('card_logo'));

  // ===== Verifications =====
  Future<void> verifyCardDetailPageDisplayed() async {
    expect(_appBar, findsOneWidget, reason: 'AppBar should be visible');
    expect(_codeDisplay, findsOneWidget, reason: 'Code should be displayed');
  }

  Future<void> verifyCardTitle(String expectedTitle) async {
    expect(
      find.text(expectedTitle),
      findsOneWidget,
      reason: 'Card title "$expectedTitle" should be displayed',
    );
  }

  Future<void> verifyCardDescription(String expectedDescription) async {
    expect(
      find.text(expectedDescription),
      findsOneWidget,
      reason: 'Card description should be displayed',
    );
  }

  Future<void> verifyCodeVisible() async {
    expect(
      _codeDisplay,
      findsOneWidget,
      reason: 'Code (barcode/QR) should be visible',
    );
  }

  Future<void> verifyCardType(String expectedType) async {
    expect(
      _cardTypeChip,
      findsOneWidget,
      reason: 'Card type chip should be visible',
    );
    expect(
      find.descendant(of: _cardTypeChip, matching: find.text(expectedType)),
      findsOneWidget,
      reason: 'Card type should be "$expectedType"',
    );
  }

  Future<void> verifyExpiryDateVisible() async {
    expect(
      _expiryChip,
      findsOneWidget,
      reason: 'Expiry date chip should be visible for a temporary card',
    );
  }

  Future<void> verifyExpiryDateNotVisible() async {
    expect(
      _expiryChip,
      findsNothing,
      reason: 'Expiry date chip should not be visible for a permanent card',
    );
  }

  Future<void> verifyActionButtonsVisible() async {
    expect(
      _editButton,
      findsOneWidget,
      reason: 'Edit button should be visible',
    );
    expect(
      _shareButton,
      findsOneWidget,
      reason: 'Share button should be visible',
    );
    expect(
      _deleteButton,
      findsOneWidget,
      reason: 'Delete button should be visible',
    );
  }

  Future<void> verifyLogoDisplayed() async {
    expect(_logoDisplay, findsOneWidget, reason: 'Logo should be displayed');
  }

  // ===== Actions =====
  Future<void> tapEditButton() async {
    await tester.tap(_editButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapShareButton() async {
    await tester.tap(_shareButton);
    await tester.pump();
  }

  Future<void> tapDeleteButton() async {
    await tester.tap(_deleteButton);
    await tester.pump();
  }

  Future<void> tapCopyButton() async {
    await tester.tap(_copyButton);
    await tester.pump();
  }

  Future<void> tapBackButton() async {
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
  }

  Future<void> confirmDeleteDialog() async {
    // Find and tap the "Delete" button in the confirmation dialog
    final deleteInDialog = find.byType(TextButton).last;
    await tester.tap(deleteInDialog);
    await tester.pumpAndSettle();
  }

  Future<void> cancelDeleteDialog() async {
    // Find and tap the "Cancel" button in the confirmation dialog
    final cancelButton = find.byType(TextButton).first;
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();
  }
}
