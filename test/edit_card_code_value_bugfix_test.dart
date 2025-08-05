import 'package:cards/l10n/app_localizations.dart';
import 'package:cards/models/card_item.dart';
import 'package:cards/pages/edit_card_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fast unit tests for the bugfix that ensures code values (QR code/barcode data)
/// are properly saved when editing cards. These tests focus on the core logic
/// without database operations to run quickly.
void main() {
  group('Edit Card Code Value Bugfix Tests', () {
    late CardItem testCard;

    setUp(() {
      testCard = CardItem(
        id: 1,
        title: 'Test Loyalty Card',
        description: 'Test Description',
        name: 'ORIGINAL_CODE_123',
        cardType: CardType.qrCode,
        sortOrder: 0,
        logoPath: null,
      );
    });

    testWidgets('EditCardPage correctly saves code value changes', (
      WidgetTester tester,
    ) async {
      CardItem? savedCard;

      // Create edit card page with onSave callback to capture the result
      final editCardPage = MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: EditCardPage(
          card: testCard,
          onSave: (updatedCard) {
            savedCard = updatedCard;
          },
        ),
      );

      await tester.pumpWidget(editCardPage);
      await tester.pumpAndSettle();

      // Find the code value text field by looking for the TextField with our test value
      final codeField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.controller?.text == 'ORIGINAL_CODE_123',
      );
      expect(codeField, findsOneWidget);

      // Change the code value
      await tester.enterText(codeField, 'NEW_CODE_456');
      await tester.pumpAndSettle();

      // Find and tap the save button
      final saveButton = find.byIcon(Icons.save);
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify the saved card has the new code value
      expect(savedCard, isNotNull);
      expect(savedCard!.name, equals('NEW_CODE_456'));
      expect(savedCard!.title, equals('Test Loyalty Card'));
      expect(savedCard!.description, equals('Test Description'));
      expect(savedCard!.cardType, equals(CardType.qrCode));
    });

    testWidgets(
      'EditCardPage correctly saves all fields including code value',
      (WidgetTester tester) async {
        CardItem? savedCard;

        final editCardPage = MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EditCardPage(
            card: testCard,
            onSave: (updatedCard) {
              savedCard = updatedCard;
            },
          ),
        );

        await tester.pumpWidget(editCardPage);
        await tester.pumpAndSettle();

        // Find fields by their specific text content
        final titleField = find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.controller?.text == 'Test Loyalty Card',
        );
        final descField = find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.controller?.text == 'Test Description',
        );
        final codeField = find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.controller?.text == 'ORIGINAL_CODE_123',
        );

        // Modify all fields
        await tester.enterText(titleField, 'Updated Title');
        await tester.pumpAndSettle();

        await tester.enterText(descField, 'Updated Description');
        await tester.pumpAndSettle();

        await tester.enterText(codeField, 'UPDATED_CODE_789');
        await tester.pumpAndSettle();

        // Change card type to barcode
        final dropdown = find.byType(DropdownButtonFormField<CardType>);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        final barcodeOption = find.text('Barcode').last;
        await tester.tap(barcodeOption);
        await tester.pumpAndSettle();

        // Save the changes
        final saveButton = find.byIcon(Icons.save);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Verify all fields are saved correctly
        expect(savedCard, isNotNull);
        expect(savedCard!.title, equals('Updated Title'));
        expect(savedCard!.description, equals('Updated Description'));
        expect(savedCard!.name, equals('UPDATED_CODE_789'));
        expect(savedCard!.cardType, equals(CardType.barcode));
      },
    );

    testWidgets('EditCardPage detects code value changes correctly', (
      WidgetTester tester,
    ) async {
      final editCardPage = MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: EditCardPage(
          card: testCard,
          onSave: (updatedCard) {
            // Save callback
          },
        ),
      );

      await tester.pumpWidget(editCardPage);
      await tester.pumpAndSettle();

      // Initially save button should be disabled (no changes)
      final saveButton = find.byIcon(Icons.save);
      expect(saveButton, findsOneWidget);
      
      // Find the IconButton that contains the save icon
      final saveIconButton = find.ancestor(
        of: saveButton,
        matching: find.byType(IconButton),
      );
      expect(saveIconButton, findsOneWidget);
      
      IconButton button = tester.widget(saveIconButton);
      expect(button.onPressed, isNull);

      // Change only the code value
      final codeField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.controller?.text == 'ORIGINAL_CODE_123',
      );
      await tester.enterText(codeField, 'CHANGED_CODE');
      await tester.pumpAndSettle();

      // Now save button should be enabled
      final updatedSaveIconButton = find.ancestor(
        of: find.byIcon(Icons.save),
        matching: find.byType(IconButton),
      );
      IconButton updatedButton = tester.widget(updatedSaveIconButton);
      expect(updatedButton.onPressed, isNotNull);
    });

    test('CardItem copyWith preserves code value correctly', () {
      // Test the model layer
      final originalCard = CardItem(
        id: 1,
        title: 'Original Title',
        description: 'Original Description',
        name: 'ORIGINAL_CODE',
        cardType: CardType.qrCode,
        sortOrder: 0,
        logoPath: null,
      );

      final updatedCard = originalCard.copyWith(name: 'UPDATED_CODE');

      expect(updatedCard.name, equals('UPDATED_CODE'));
      expect(updatedCard.title, equals('Original Title'));
      expect(updatedCard.description, equals('Original Description'));
      expect(updatedCard.cardType, equals(CardType.qrCode));
      expect(updatedCard.id, equals(1));
    });

    test(
      'CardItem copyWith handles all field updates including code value',
      () {
        final originalCard = CardItem(
          id: 1,
          title: 'Original Title',
          description: 'Original Description',
          name: 'ORIGINAL_CODE',
          cardType: CardType.qrCode,
          sortOrder: 0,
          logoPath: 'original_logo.svg',
        );

        final updatedCard = originalCard.copyWith(
          title: 'New Title',
          description: 'New Description',
          name: 'NEW_CODE_VALUE',
          cardType: CardType.barcode,
          logoPath: 'new_logo.svg',
        );

        expect(updatedCard.name, equals('NEW_CODE_VALUE'));
        expect(updatedCard.title, equals('New Title'));
        expect(updatedCard.description, equals('New Description'));
        expect(updatedCard.cardType, equals(CardType.barcode));
        expect(updatedCard.logoPath, equals('new_logo.svg'));
        expect(updatedCard.id, equals(1)); // Should preserve ID
      },
    );
  });
}
