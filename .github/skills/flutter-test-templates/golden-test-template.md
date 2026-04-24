# Golden Test Template (Visual Regression)

Create in `test/goldens/`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:cards/pages/login/login_page.dart';
import 'package:cards/services/auth_service.dart';
import 'package:mocktail/mocktail.dart';

// Mock service
class MockAuthService extends Mock implements AuthService {}

// Device configurations for testing multiple screen sizes
const devices = [
  Device.phone,      // Pixel 5 (small phone)
  Device.tabletPortrait,  // Larger screen
  Device.tabletLandscape, // Wide screen
];

void main() {
  group('Golden Tests - Login Page', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    // Test login page in different states across multiple devices
    for (final device in devices) {
      testWidgets(
        'Login page empty state on ${device.name}',
        (WidgetTester tester) async {
          await tester.binding.window.physicalSizeTestValue = device.size;
          addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

          await tester.pumpWidget(
            MaterialApp(
              home: LoginPage(authService: mockAuthService),
            ),
          );

          // Golden file naming: golden_<widget>_<state>_<device>.png
          await expectLater(
            find.byType(LoginPage),
            matchesGoldenFile('golden_login_page_empty_${device.name}.png'),
          );
        },
        tags: ['golden'],
      );
    }

    // Test with pre-filled form
    testWidgets(
      'Login page with filled fields',
      (WidgetTester tester) async {
        const device = Device.phone;
        tester.binding.window.physicalSizeTestValue = device.size;
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          MaterialApp(
            home: LoginPage(authService: mockAuthService),
          ),
        );

        // Fill in fields
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
          '••••••••••',
        );

        await tester.pump();

        await expectLater(
          find.byType(LoginPage),
          matchesGoldenFile('golden_login_page_filled_phone.png'),
        );
      },
      tags: ['golden'],
    );

    // Test error state
    testWidgets(
      'Login page with error message',
      (WidgetTester tester) async {
        const device = Device.phone;
        tester.binding.window.physicalSizeTestValue = device.size;
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          MaterialApp(
            home: LoginPage(
              authService: mockAuthService,
              initialError: 'Invalid credentials. Please try again.',
            ),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(LoginPage),
          matchesGoldenFile('golden_login_page_error_phone.png'),
        );
      },
      tags: ['golden'],
    );

    // Test loading state
    testWidgets(
      'Login page loading state',
      (WidgetTester tester) async {
        const device = Device.phone;
        tester.binding.window.physicalSizeTestValue = device.size;
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          MaterialApp(
            home: LoginPage(
              authService: mockAuthService,
              isLoading: true,
            ),
          ),
        );

        await tester.pump();

        await expectLater(
          find.byType(LoginPage),
          matchesGoldenFile('golden_login_page_loading_phone.png'),
        );
      },
      tags: ['golden'],
    );
  });

  group('Golden Tests - Custom Widgets', () {
    testWidgets(
      'CardWidget displays correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  height: 200,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Card Title',
                            style: Theme.of(tester.element(find.byType(Card)))
                                .textTheme
                                .headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'This is a card widget used throughout the app.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(Card),
          matchesGoldenFile('golden_card_widget_standard.png'),
        );
      },
      tags: ['golden'],
    );
  });
}
```

---

## Golden Testing with Multiple Screen Densities

```dart
// Device configurations for Multiple Screen Tests
const devices = [
  Device(
    name: 'pixel_3',
    size: Size(1080, 1920),
    devicePixelRatio: 2.75,
  ),
  Device(
    name: 'pixel_5',
    size: Size(1080, 2340),
    devicePixelRatio: 2.75,
  ),
  Device(
    name: 'tablet_ipad',
    size: Size(2048, 2732),
    devicePixelRatio: 2.0,
  ),
];
```

---

## Running Golden Tests

**Generate (or update) golden files:**
```bash
flutter test --tags=golden --update-goldens
```

**Verify golden files without updating:**
```bash
flutter test --tags=golden
```

**Run specific golden test:**
```bash
flutter test test/goldens/login_golden_test.dart --tags=golden
```

**Generate and commit:**
```bash
flutter test --tags=golden --update-goldens
git add test/goldens/
git commit -m "Update golden images for login page redesign"
```

---

## Golden Test Storage & Organization

```
test/goldens/
  ├── login_golden_test.dart
  ├── home_golden_test.dart
  ├── settings_golden_test.dart
  └── goldens/  # Generated golden images (git-tracked)
      ├── golden_login_page_empty_phone.png
      ├── golden_login_page_filled_phone.png
      ├── golden_login_page_error_phone.png
      ├── golden_home_page_hdpi.png
      ├── golden_home_page_xhdpi.png
      └── golden_home_page_xxhdpi.png
```

---

## CI/CD Integration for Golden Tests

In your GitHub Actions workflow, golden diffs are uploaded as artifacts on failure:

```yaml
- name: Run golden tests
  run: flutter test --tags=golden

- name: Upload golden diffs on failure
  if: failure()
  uses: actions/upload-artifact@v3
  with:
    name: golden-diffs
    path: test/goldens/failures/
```

**Review diffs in CI**: When a golden test fails, download the artifact to see the diff visually.

---

## Best Practices for Golden Tests

✅ **Test Critical UI Screens**: Home, login, settings, main flows  
✅ **Multiple Densities**: Test on hdpi, xhdpi, xxhdpi (small, medium, large phones)  
✅ **Test All States**: Empty, loading, error, success, disabled  
✅ **Version Control Goldens**: Commit `.png` files to git  
✅ **Review Before Updating**: Always visually review golden diffs before `--update-goldens`  
✅ **Avoid Golden Bloat**: Don't test every tiny widget—focus on pages and complex components  
✅ **Deterministic Tests**: Ensure golden tests don't depend on time/random data  
✅ **Mock External Data**: Use fake data that's consistent across runs  

---

## Troubleshooting Golden Tests

**Golden not matching after UI change?**  
→ Review the diff in the test runner, confirm change is intentional, then `--update-goldens`

**Golden file not found locally?**  
→ Run `flutter test --tags=golden --update-goldens` once to generate

**Flaky goldens on CI but not local?**  
→ May be font rendering, theme differences. Ensure CI machine has same Flutter versions
