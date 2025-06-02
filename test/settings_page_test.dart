import 'package:cards/l10n/app_localizations.dart';
import 'package:cards/pages/settings_page.dart';
import 'package:cards/utils/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget createSettingsPage() {
  return const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: SettingsPage(),
  );
}

void main() {
  setUpAll(() async {
    // Mock SharedPreferences for AppSettings
    SharedPreferences.setMockInitialValues({
      'language_code': 'en', // Default language for tests
      'theme_mode': 'system', // Default theme for tests
    });
    await AppSettings.init();
  });

  testWidgets('SettingsPage displays initial language and theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createSettingsPage());
    await tester.pumpAndSettle();
    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    expect(find.text(l10n.settings), findsOneWidget); // AppBar title
    expect(find.text(l10n.language), findsOneWidget);
    expect(find.text(l10n.english), findsOneWidget); // Assuming default is 'en'
    expect(find.text(l10n.theme), findsOneWidget);
    expect(
      find.text(l10n.system),
      findsOneWidget,
    ); // Assuming default is 'system'
  });

  testWidgets('SettingsPage opens language selection dialog', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createSettingsPage());
    await tester.pumpAndSettle();
    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    await tester.tap(find.text(l10n.language));
    await tester.pumpAndSettle(); // Show dialog

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(l10n.selectLanguage), findsOneWidget); // Dialog title
    expect(find.text(l10n.english), findsWidgets); // Option in dialog
    expect(find.text(l10n.spanish), findsWidgets); // Option in dialog
    expect(find.text(l10n.dutch), findsWidgets); // Option in dialog
  });

  testWidgets('SettingsPage opens theme selection dialog', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createSettingsPage());
    await tester.pumpAndSettle();
    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    await tester.tap(find.text(l10n.theme));
    await tester.pumpAndSettle(); // Show dialog

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(l10n.selectTheme), findsOneWidget); // Dialog title
    expect(find.text(l10n.light), findsWidgets); // Option in dialog
    expect(find.text(l10n.dark), findsWidgets); // Option in dialog
    expect(find.text(l10n.system), findsWidgets); // Option in dialog
  });

  testWidgets('SettingsPage changes language', (WidgetTester tester) async {
    await tester.pumpWidget(createSettingsPage());
    await tester.pumpAndSettle();
    // Load English localizations for initial state and for finding elements by their English text
    AppLocalizations englishL10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    // Open language dialog
    await tester.tap(find.text(englishL10n.language));
    await tester.pumpAndSettle();

    // Select Spanish. The option in the dialog will be labeled "Spanish" (using englishL10n).
    await tester.tap(find.text(englishL10n.spanish).last);
    await tester
        .pumpAndSettle(); // Dialog closes, settings update, page rebuilds

    // Verify AppSettings reflects the change
    expect(AppSettings.getLanguageCode(), 'es');

    // The SettingsPage UI will now display "Spanish" as the subtitle for the language setting.
    // This is because _currentLanguage state is 'es', and _getLanguageName('es', l10nFromContext)
    // will use the l10nFromContext (which is still English in this test's MaterialApp)
    // to get the display name for 'es', resulting in englishL10n.spanish ("Spanish").
    expect(find.text(englishL10n.spanish), findsOneWidget);
  });

  testWidgets('SettingsPage changes theme', (WidgetTester tester) async {
    await tester.pumpWidget(createSettingsPage());
    await tester.pumpAndSettle();
    AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    // Open theme dialog
    await tester.tap(find.text(l10n.theme));
    await tester.pumpAndSettle();

    // Select Dark theme
    await tester.tap(find.text(l10n.dark).last);
    await tester.pumpAndSettle();

    expect(AppSettings.getThemeMode(), 'dark');
    expect(find.text(l10n.dark), findsOneWidget); // Subtitle should be Dark
    expect(
      find.byIcon(Icons.nightlight_round),
      findsOneWidget,
    ); // Check for dark theme icon
  });
}
