import 'package:cards/widgets/logo_avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_icons/simple_icons.dart';

void main() {
  group('Logo Display Tests', () {
    testWidgets('LogoAvatarWidget should display Simple Icon correctly', (
      WidgetTester tester,
    ) async {
      // Test with direct IconData
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LogoAvatarWidget(
              logoIcon: SimpleIcons.starbucks,
              title: 'Starbucks',
              size: 48,
            ),
          ),
        ),
      );

      // Should find the icon, not the initials
      expect(find.byIcon(SimpleIcons.starbucks), findsOneWidget);
      expect(find.text('ST'), findsNothing); // Should not show initials
    });

    testWidgets('LogoAvatarWidget should display Simple Icon via logoKey', (
      WidgetTester tester,
    ) async {
      // Test with simple_icon: prefix
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LogoAvatarWidget(
              logoKey: 'simple_icon:starbucks',
              title: 'Starbucks',
              size: 48,
            ),
          ),
        ),
      );

      // Should find the icon
      expect(find.byIcon(SimpleIcons.starbucks), findsOneWidget);
      expect(find.text('ST'), findsNothing); // Should not show initials
    });

    testWidgets('LogoAvatarWidget should fall back to initials when no logo', (
      WidgetTester tester,
    ) async {
      // Test fallback to initials
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LogoAvatarWidget(title: 'Test Card', size: 48)),
        ),
      );

      // Should show initials
      expect(find.text('TE'), findsOneWidget);
    });
  });
}
