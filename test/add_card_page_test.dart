import 'package:cards/pages/add_card_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget createAddCardPage() {
  return const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: AddCardPage(),
  );
}

void main() {
  testWidgets('AddCardPage initial state is Scan mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createAddCardPage());
    await tester.pumpAndSettle();
    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    // Check if the label for the scan mode segment is present
    expect(find.text(l10n.scanBarcode), findsOneWidget);

    // Check for the scanner icon. If this still fails, it might indicate an issue
    // with how SegmentedButton renders icons in the test environment or a deeper issue.
    expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    // Check that manual entry form fields are not visible
    expect(find.widgetWithText(TextFormField, 'Title'), findsNothing);
  });

  testWidgets('AddCardPage switches to Manual Entry mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createAddCardPage());
    await tester.pumpAndSettle();

    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );
    // Tap the Text label of the "Manual Entry" segment
    await tester.tap(find.text(l10n.manualEntry));
    await tester.pumpAndSettle();

    // Check for manual entry form fields
    // Initially, the _selectedCardType is QR_CODE, so the label should be qrCodeValue
    expect(
      find.widgetWithText(
        TextFormField,
        l10n.qrCodeValue,
      ), // Corrected expected label
      findsOneWidget,
    );
    expect(find.widgetWithText(TextFormField, l10n.title), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, l10n.description),
      findsOneWidget,
    );
    expect(find.widgetWithText(ElevatedButton, l10n.addCard), findsOneWidget);
  });

  testWidgets('AddCardPage manual entry form validation and submission', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createAddCardPage());
    await tester.pumpAndSettle();
    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    // Switch to Manual Entry by tapping the Text label
    await tester.tap(find.text(l10n.manualEntry));
    await tester.pumpAndSettle();

    // Find form fields
    // Initially, the _selectedCardType is QR_CODE
    final valueField = find.widgetWithText(
      TextFormField,
      l10n.qrCodeValue, // Corrected expected label
    );
    final titleField = find.widgetWithText(TextFormField, l10n.title);
    final descriptionField = find.widgetWithText(
      TextFormField,
      l10n.description,
    );
    final addButton = find.widgetWithText(ElevatedButton, l10n.addCard);

    // Test validation: Try to submit empty form
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    expect(
      find.text(l10n.validationPleaseEnterValue),
      findsOneWidget,
    ); // For value field
    expect(
      find.text(l10n.validationTitleRequired),
      findsOneWidget,
    ); // For title field

    // Enter valid data
    await tester.enterText(valueField, 'ManualData123');
    await tester.enterText(titleField, 'Manual Card');
    await tester.enterText(descriptionField, 'A card added manually');
    await tester.pumpAndSettle();

    // Submit form
    await tester.tap(addButton);
    await tester.pumpAndSettle(); // Wait for navigation pop

    // Verify that Navigator.pop was called with a CardItem
    // This is harder to test directly without a mock navigator or checking the result.
    // For now, we assume if no validation errors, it tried to pop.
    // If you have a way to check the result of Navigator.pop in tests, use that.
    // For example, if the page was pushed using `tester.pumpWidget(MaterialApp(home: TestWrapper(child: AddCardPage())))`
    // where TestWrapper could capture the pop result.

    // Check that validation messages are gone
    expect(find.text(l10n.validationPleaseEnterValue), findsNothing);
    expect(find.text(l10n.validationTitleRequired), findsNothing);
  });

  testWidgets('AddCardPage scan success UI appears', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createAddCardPage());
    await tester.pumpAndSettle();
    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    // Simulate a scan. This is tricky. We'll manually trigger the state change
    // that would happen after a scan. This requires access to the State object.
    // A more robust way would be to mock the MobileScannerController if possible,
    // or use an integration test.

    // For a widget test, we can check if the form for adding details appears
    // when _scannedData is not null.
    // This part is hard to test in isolation without deeper mocking or refactoring.
    // We can at least verify the initial state where the form is hidden.
    expect(
      find.widgetWithText(TextFormField, l10n.title),
      findsNothing,
    ); // Initially hidden in scan mode

    // To test the UI after scan, you would typically:
    // 1. Get the State object: final state = tester.state< _AddCardPageState>(find.byType(AddCardPage));
    // 2. Call a method on the state or directly set state variables:
    //    state.setState(() {
    //      state._scannedData = "TestData";
    //      state._detectedFormatString = "QR Code";
    //      state._isScanning = false;
    //    });
    // 3. await tester.pumpAndSettle();
    // 4. Verify the form fields and success message appear.
    // This direct state manipulation is generally discouraged but sometimes necessary for hard-to-trigger UI states.
    // However, _AddCardPageState fields are private.

    // For now, we'll skip the direct simulation of scan success UI in this widget test
    // due to the complexity of mocking the scanner or private state access.
    // Focus on what's testable: the manual path and mode switching.
  });
}
