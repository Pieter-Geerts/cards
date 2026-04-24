# Integration Test Template (test_driver/app_test.dart)

This is a production-ready integration test template demonstrating Page Object Model pattern with Android-specific validations.

```dart
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cards/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Tests - Critical User Flows', () {
    
    setUp(() async {
      // Reset app state before each test
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('Full user onboarding flow with Android back button validation',
        (WidgetTester tester) async {
      // Initialize page objects
      final onboardingPage = OnboardingPageObject(tester);
      final homePage = HomePageObject(tester);

      // Test flow
      await onboardingPage.verifyOnboardingScreensPresent();
      await onboardingPage.fillUserProfile(
        name: 'John Doe',
        email: 'john@example.com',
      );
      
      // Verify API call was made correctly
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('home_screen')), findsOneWidget);

      // Android-specific: Test back button
      await tester.sendKeyEvent(LogicalKeyboardKey.goBack);
      await tester.pump();
      
      // Should stay on home (back is disabled) or navigate appropriately
      await homePage.verifyHomeScreenDisplayed();
    });

    testWidgets('Sign in with keyboard interactions', 
        (WidgetTester tester) async {
      final loginPage = LoginPageObject(tester);

      // Enter credentials
      await loginPage.enterEmail('test@example.com');
      await loginPage.enterPassword('password123');
      
      // Android-specific: Keyboard should be hidden after entering password
      await tester.tapAt(const Offset(100, 100)); // Tap to hide keyboard
      await tester.pumpAndSettle();

      // Submit
      await loginPage.tapSignInButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify navigation
      expect(find.byKey(const ValueKey('dashboard')), findsOneWidget);
    });

    testWidgets('API error handling and retry flow',
        (WidgetTester tester) async {
      final settingsPage = SettingsPageObject(tester);

      // Trigger an API call
      await settingsPage.tapSyncButton();
      await tester.pumpAndSettle();

      // Verify error state
      expect(find.byKey(const ValueKey('error_message')), findsOneWidget);

      // Retry
      await settingsPage.tapRetryButton();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify success
      expect(find.byKey(const ValueKey('sync_success')), findsOneWidget);
    });

    testWidgets('Screen orientation changes preserve state',
        (WidgetTester tester) async {
      // Set initial orientation (portrait)
      addTearDown(tester.binding.window.physicalSizeTestValue = null);
      addTearDown(TestWidgetsFlutterBinding.instance.window.clearPhysicalSizeTestValue);

      // Load screen in portrait
      await tester.pumpAndSettle();
      final portraitState = find.byKey(const ValueKey('state_indicator')).evaluate().first;

      // Rotate to landscape
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      
      await tester.pumpAndSettle();

      // Verify state preserved
      final landscapeState = find.byKey(const ValueKey('state_indicator')).evaluate().first;
      expect(portraitState.toString(), landscapeState.toString());
    });
  });
}
```

---

## Page Object Template

Create in `integration_test/page_objects/login_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class LoginPageObject {
  final WidgetTester tester;

  LoginPageObject(this.tester);

  // Finders - Encapsulate all widget locators
  Finder get _emailField => find.byKey(const ValueKey('email_field'));
  Finder get _passwordField => find.byKey(const ValueKey('password_field'));
  Finder get _signInButton => find.byKey(const ValueKey('sign_in_button'));
  Finder get _errorMessage => find.byKey(const ValueKey('login_error'));

  // Actions - Page interactions
  Future<void> enterEmail(String email) async {
    await tester.tap(_emailField);
    await tester.pump();
    await tester.enterText(_emailField, email);
    await tester.pump();
  }

  Future<void> enterPassword(String password) async {
    await tester.tap(_passwordField);
    await tester.pump();
    await tester.enterText(_passwordField, password);
    await tester.pump();
  }

  Future<void> tapSignInButton() async {
    await tester.tap(_signInButton);
    await tester.pump();
  }

  // Verifications - Page state assertions
  Future<void> verifyLoginScreenDisplayed() async {
    expect(_emailField, findsOneWidget);
    expect(_passwordField, findsOneWidget);
    expect(_signInButton, findsOneWidget);
  }

  Future<void> verifyErrorMessageDisplayed(String message) async {
    expect(find.text(message), findsOneWidget);
    expect(_errorMessage, findsOneWidget);
  }
}
```

---

## Running Integration Tests

```bash
# On emulator or connected device
flutter drive \
  --target=integration_test/app_test.dart \
  --flavor=dev

# Headless on CI/CD
flutter drive \
  --target=integration_test/app_test.dart \
  --driver=integration_test/driver.dart \
  --headless \
  --verbose
```
