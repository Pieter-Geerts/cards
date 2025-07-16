import 'package:cards/widgets/logo_avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LogoAvatarWidget displays initials when no logoKey', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LogoAvatarWidget(
            logoKey: null,
            title: 'Test', // Should produce 'TE' as initials
            size: 48,
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('logo-initials')), findsOneWidget);
  });
}
