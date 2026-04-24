# E2E Tests Quick Start

## Installation

1. Ensure `integration_test` is in `pubspec.yaml` dev_dependencies:
```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
```

2. Run dependencies:
```bash
flutter pub get
```

## Running Tests

### Test Locally (Fastest)
```bash
# All integration tests
flutter test integration_test/

# Single test file
flutter test integration_test/add_card_flows_test.dart

# Specific test case
flutter test integration_test/add_card_flows_test.dart -k "manual add card"
```

### On Android Emulator
```bash
# Make sure emulator is running
flutter emulators --launch pixel_6_pro

# Then run with driver
flutter drive \
  --target=integration_test/add_card_flows_test.dart \
  --driver=test_driver/driver.dart
```

### Headless (CI/CD)
```bash
flutter drive \
  --target=integration_test/add_card_flows_test.dart \
  --headless \
  --device-id emulator-5554
```

## Test Structure

All tests in `add_card_flows_test.dart` follow the **AAA Pattern**:

```dart
testWidgets('test description', (WidgetTester tester) async {
  // ===== ARRANGE =====
  await tester.pumpWidget(const MyApp());
  
  // ===== ACT =====
  await homePage.tapAddCardFAB();
  
  // ===== ASSERT =====
  await addCardEntryPage.verifyPageDisplayed();
});
```

## Coverage Report

```bash
# Generate coverage
flutter test integration_test/ --coverage

# View report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Tests timeout | Increase timeout: `timeout: const Timeout(Duration(seconds: 120))` |
| Widget not found | Check ValueKeys match in UI and page objects |
| Navigation doesn't work | Use `pumpAndSettle()` after navigation |
| Emulator too slow | Use `-api-level 28` (no instant run overhead) |
| Permission denied on CI | Ensure GitHub Actions has proper permissions |

## Key Files

- `integration_test/add_card_flows_test.dart` - Main test suite
- `integration_test/page_objects/` - UI abstraction layer
- `integration_test/helpers/test_helpers.dart` - Test utilities
- `integration_test/README.md` - Full documentation
