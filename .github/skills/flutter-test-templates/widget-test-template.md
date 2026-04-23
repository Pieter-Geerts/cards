# Widget Test Template

Create in `test/widget/`: 

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cards/pages/login/login_page.dart';
import 'package:cards/services/auth_service.dart';
import 'package:mocktail/mocktail.dart';

// Mock Authentication Service
class MockAuthService extends Mock implements AuthService {}

void main() {
  group('LoginPage Widget Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    // Helper function to build the widget under test
    Future<void> pumpLoginPage(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(authService: mockAuthService),
        ),
      );
    }

    testWidgets('Login page displays email and password fields',
        (WidgetTester tester) async {
      await pumpLoginPage(tester);

      expect(find.byKey(const ValueKey('email_field')), findsOneWidget);
      expect(find.byKey(const ValueKey('password_field')), findsOneWidget);
      expect(find.byKey(const ValueKey('sign_in_button')), findsOneWidget);
    });

    testWidgets('Sign in button is disabled when fields are empty',
        (WidgetTester tester) async {
      await pumpLoginPage(tester);

      final signInButton = find.byKey(const ValueKey('sign_in_button'));
      expect(signInButton, findsOneWidget);

      // Verify button has disabled styling (e.g., opacity or GestureDetector state)
      final buttonWidget = tester.widget<ElevatedButton>(signInButton);
      expect(buttonWidget.onPressed, isNull);
    });

    testWidgets('Sign in button is enabled when both fields are filled',
        (WidgetTester tester) async {
      await pumpLoginPage(tester);

      await tester.tap(find.byKey(const ValueKey('email_field')));
      await tester.pump();
      await tester.enterText(
        find.byKey(const ValueKey('email_field')),
        'test@example.com',
      );

      await tester.tap(find.byKey(const ValueKey('password_field')));
      await tester.pump();
      await tester.enterText(
        find.byKey(const ValueKey('password_field')),
        'password123',
      );

      await tester.pump();

      final buttonWidget = tester.widget<ElevatedButton>(
        find.byKey(const ValueKey('sign_in_button')),
      );
      expect(buttonWidget.onPressed, isNotNull);
    });

   
}
```

---

## Key Widget Testing Practices

✅ **Use Keys for Finding**: Every interactive widget should have a `ValueKey` for reliable test finding  
✅ **Mock Dependencies**: Use `mocktail` for clean, no-codegen mocking  
✅ **Test User Interactions**: `tap()`, `enterText()`, `pump()`  
✅ **Verify State Changes**: Check widget presence and properties after interactions  
✅ **Test Error States**: Verify error messages and loading indicators  
✅ **Keep Tests Isolated**: Each test is independent; no state carried between tests
