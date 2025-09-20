import 'package:cards/widgets/card_preview_widget.dart';
import 'package:cards/widgets/logo_avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CardPreviewWidget displays logo, title, and description', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CardPreviewWidget(
            logoPath: null,
            title: 'Test Title',
            description: 'Test Description',
            logoSize: 48,
            background: Colors.white,
          ),
        ),
      ),
    );
    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Test Description'), findsOneWidget);
    expect(find.byType(LogoAvatarWidget), findsOneWidget);
  });

  testWidgets('CardPreviewWidget hides description if empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CardPreviewWidget(
            logoPath: null,
            title: 'Test Title',
            description: '',
          ),
        ),
      ),
    );
    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text(''), findsNothing);
  });
}
