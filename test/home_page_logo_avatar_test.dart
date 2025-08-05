import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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

  // Skipped: HomePage displays LogoAvatarWidget for each card
  /*
  testWidgets('HomePage displays LogoAvatarWidget for each card', (WidgetTester tester) async {
    final cards = [
      CardItem(
        id: 1,
        title: 'Carrefour',
        description: 'Test',
        name: '123',
        cardType: CardType.barcode,
        sortOrder: 0,
        logoPath: null, // Always use null for initials in tests
      ),
      CardItem(
        id: 2,
        title: 'Lidl',
        description: 'Lidl',
        name: '456',
        cardType: CardType.qrCode,
        sortOrder: 1,
        logoPath: null, // Always use null for initials in tests
      ),
    ];
    await tester.pumpWidget(
      _wrapWithMaterialApp(HomePage(cards: cards, onAddCard: (_) {})),
    );
    await tester.pumpAndSettle();
    // There should be a LogoAvatarWidget for each card
    expect(find.byType(LogoAvatarWidget), findsNWidgets(cards.length));
    // The first card should show a logo or initials
    expect(find.text('CA'), findsOneWidget); // Initials for Carrefour
    expect(find.text('LI'), findsOneWidget); // Initials for Lidl
  });
  */
}
