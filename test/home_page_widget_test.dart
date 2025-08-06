import 'package:cards/l10n/app_localizations.dart';
import 'package:cards/models/card_item.dart';
import 'package:cards/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget createHomePage({
  required List<CardItem> cards,
  required Function(CardItem) onAddCard,
  Locale? locale,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale ?? const Locale('nl'),
    home: HomePage(cards: cards, onAddCard: onAddCard),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final binding = TestDefaultBinaryMessengerBinding.instance;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('screen_brightness'),
      (call) async {
        if (call.method == 'getScreenBrightness') return 0.5;
        if (call.method == 'setScreenBrightness') return null;
        if (call.method == 'resetScreenBrightness') return null;
        return null;
      },
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => '/tmp',
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/file_selector'),
      (call) async => null,
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/share_plus'),
      (call) async => null,
    );
  });

  testWidgets('HomePage displays card title and description', (
    WidgetTester tester,
  ) async {
    final cards = [
      CardItem(
        id: 1,
        title: 'Carrefour',
        description: 'Test',
        name: '123',
        cardType: CardType.barcode,
        sortOrder: 0,
        logoPath: null,
      ),
    ];
    await tester.pumpWidget(createHomePage(cards: cards, onAddCard: (_) {}));
    await tester.pumpAndSettle();
    expect(find.text('Carrefour'), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
  });

  testWidgets('HomePage shows empty state when no cards', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createHomePage(cards: [], onAddCard: (_) {}));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.credit_card), findsOneWidget);
    final l10n = await AppLocalizations.delegate.load(const Locale('nl'));
    expect(find.text(l10n.noCardsYet), findsOneWidget);
  });

  testWidgets('HomePage floating action button is present', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createHomePage(cards: [], onAddCard: (_) {}));
    await tester.pumpAndSettle();
    // There are two add icons: one in the FAB, one in the empty state button. At least one should be present.
    expect(find.byType(FloatingActionButton), findsOneWidget);
    // Optionally, check for the FAB specifically:
    expect(find.byIcon(Icons.add).evaluate().isNotEmpty, isTrue);
  });
}
