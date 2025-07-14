import 'package:cards/l10n/app_localizations.dart';
import 'package:cards/pages/add_card_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget createAddCardPage() {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const AddCardPage(),
  );
}

void main() {
  testWidgets('AddCardPage renders and allows saving', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: AddCardPage()));
    await tester.enterText(find.byType(TextField).at(0), 'Test Card');
    await tester.enterText(find.byType(TextField).at(1), 'Test Description');
    await tester.enterText(find.byType(TextField).at(2), '123456');
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();
    // No error should occur
  });
}
