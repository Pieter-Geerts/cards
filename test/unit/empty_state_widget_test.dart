import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cards/config/app_localization.dart';
import 'package:cards/widgets/empty_state_widget.dart';

void main() {
  testWidgets(
    'EmptyStateWidget shows Add and Scan buttons and triggers callbacks',
    (WidgetTester tester) async {
      var addCalled = false;
      var scanCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizationConfig.localizationsDelegates,
          supportedLocales: AppLocalizationConfig.supportedLocales,
          home: Scaffold(
            body: EmptyStateWidget(
              onAddCard: () => addCalled = true,
              onScan: () => scanCalled = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify localized button labels are present
      expect(find.text('Add Card'), findsOneWidget);
      expect(find.text('Scan Barcode'), findsOneWidget);

      // Tap the add button via its label
      final addButtonLabel = find.text('Add Card');
      expect(addButtonLabel, findsOneWidget);
      await tester.tap(addButtonLabel);
      await tester.pump();
      expect(addCalled, isTrue);

      // Tap the scan button
      final scanButtonLabel = find.text('Scan Barcode');
      expect(scanButtonLabel, findsOneWidget);
      await tester.tap(scanButtonLabel);
      await tester.pump();
      expect(scanCalled, isTrue);
    },
  );
}
