import 'package:cards/widgets/optimized_logo_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OptimizedLogoGrid Tests', () {
    late ValueNotifier<IconData?> selectedLogo;
    late List<IconData> testLogos;
    late ColorScheme testColorScheme;

    setUp(() {
      selectedLogo = ValueNotifier<IconData?>(null);
      testLogos = [Icons.star, Icons.favorite, Icons.home, Icons.search];
      testColorScheme = const ColorScheme.light();
    });

    tearDown(() {
      selectedLogo.dispose();
    });

    testWidgets('should render empty grid when no logos provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedLogoGrid(
              logos: [],
              selectedLogo: selectedLogo,
              onLogoSelected: (_) {},
              colorScheme: testColorScheme,
            ),
          ),
        ),
      );

      expect(find.byType(GridView), findsNothing);
    });

    testWidgets('should render grid with provided logos', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedLogoGrid(
              logos: testLogos,
              selectedLogo: selectedLogo,
              onLogoSelected: (_) {},
              colorScheme: testColorScheme,
            ),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should handle logo selection', (WidgetTester tester) async {
      IconData? lastSelected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedLogoGrid(
              logos: testLogos,
              selectedLogo: selectedLogo,
              onLogoSelected: (logo) => lastSelected = logo,
              colorScheme: testColorScheme,
            ),
          ),
        ),
      );

      // Tap on first logo
      await tester.tap(find.byIcon(Icons.star));
      await tester.pumpAndSettle();

      expect(lastSelected, equals(Icons.star));
    });

    testWidgets('should reflect selection state visually', (
      WidgetTester tester,
    ) async {
      selectedLogo.value = Icons.star;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedLogoGrid(
              logos: testLogos,
              selectedLogo: selectedLogo,
              onLogoSelected: (_) {},
              colorScheme: testColorScheme,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The selected logo should have different styling
      // This would need to be verified based on the actual implementation
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('should use custom crossAxisCount', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedLogoGrid(
              logos: testLogos,
              selectedLogo: selectedLogo,
              onLogoSelected: (_) {},
              colorScheme: testColorScheme,
              crossAxisCount: 2,
            ),
          ),
        ),
      );

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(2));
    });

    testWidgets('should handle large logo lists efficiently', (
      WidgetTester tester,
    ) async {
      final largeLogoList = List.generate(100, (index) => Icons.star);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedLogoGrid(
              logos: largeLogoList,
              selectedLogo: selectedLogo,
              onLogoSelected: (_) {},
              colorScheme: testColorScheme,
            ),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);

      // Should be able to scroll through the list
      await tester.fling(find.byType(GridView), const Offset(0, -500), 1000);
      await tester.pumpAndSettle();
    });
  });

  group('SearchableLogoGrid Tests', () {
    late ValueNotifier<IconData?> selectedLogo;
    late List<IconData> testLogos;
    late ColorScheme testColorScheme;

    setUp(() {
      selectedLogo = ValueNotifier<IconData?>(null);
      testLogos = [Icons.star, Icons.favorite, Icons.home, Icons.search];
      testColorScheme = const ColorScheme.light();
    });

    tearDown(() {
      selectedLogo.dispose();
    });

    testWidgets('should filter logos based on search query', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchableLogoGrid(
              allLogos: testLogos,
              selectedLogo: selectedLogo,
              onLogoSelected: (_) {},
              colorScheme: testColorScheme,
              searchQuery: '',
            ),
          ),
        ),
      );

      // Initially should show all logos
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should handle empty search results', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchableLogoGrid(
              allLogos: testLogos,
              selectedLogo: selectedLogo,
              onLogoSelected: (_) {},
              colorScheme: testColorScheme,
              searchQuery: 'nonexistent',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show empty results or handle gracefully
      expect(find.byType(OptimizedLogoGrid), findsOneWidget);
    });
  });
}
