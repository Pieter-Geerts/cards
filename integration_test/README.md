# Integration Tests for Add Card Flows

This directory contains comprehensive end-to-end (E2E) tests for all add card flows in the Just Cards application using the **Page Object Model (POM)** pattern.

## 📋 Test Coverage

### Add Card Flow Tests (`add_card_flows_test.dart`)

All tests follow the same pattern:
1. **Arrange**: Initialize app state
2. **Act**: Perform user actions
3. **Assert**: Verify outcomes

#### Test Cases

| Test | Purpose | Android Specific |
|------|---------|-------------------|
| Complete manual add card flow - QR Code | Full workflow from home → entry → form → logo selection → detail | ✅ Navigation, back button |
| Add card flow - Barcode type selection | Verify barcode type selection and UI adjustments | ✅ Code rendering |
| Add card flow - Cancel at entry page | Back button handling at entry screen | ✅ Back button |
| Add card flow - Cancel at form page | Mid-form cancellation | ✅ Dialog handling |
| Add card flow - Multiple cards sequentially | Create multiple cards in succession | ✅ State management |
| Add card flow - Verify card details after creation | Validate created card matches input | ✅ Data persistence |
| Add card flow - Form validation (empty fields) | Required field validation | ✅ Keyboard handling |
| Add card flow - Logo selection cancel | Cancel logo selection without losing form data | ✅ Fragment state |
| Add card flow - Special characters in fields | Unicode and special character handling | ✅ Input encoding |

**Total: 9 test cases, ~8 minutes execution time**

## 📁 Directory Structure

```
integration_test/
├── add_card_flows_test.dart          # Main E2E test file
├── page_objects/                     # Page Object Model implementations
│   ├── home_page_object.dart         # Home screen interactions
│   ├── add_card_entry_page_object.dart    # Add card entry options
│   ├── add_card_form_page_object.dart     # Manual form entry
│   ├── logo_selection_page_object.dart    # Logo picker
│   └── card_detail_page_object.dart       # Card detail view
└── helpers/                          # Test utilities
    └── test_helpers.dart             # Setup, data, sync, error handling
```

## 🎯 Page Objects

### HomePageObject
- **Responsibilities**: Home screen interactions and assertions
- **Key Methods**:
  - `verifyHomePageDisplayed()` - Verify home page loaded
  - `tapAddCardFAB()` - Tap add card button
  - `verifyCardVisible(title)` - Check card in list

### AddCardEntryPageObject
- **Responsibilities**: Entry point option selection
- **Key Methods**:
  - `verifyAllOptionsAvailable()` - Check all entry options
  - `tapManualEntryButton()` - Select manual entry
  - `tapScanBarcodeButton()` - Select camera scan (mocked)

### AddCardFormPageObject
- **Responsibilities**: Form field interactions and validation
- **Key Methods**:
  - `fillFullForm()` - Fill all required fields
  - `verifySubmitButtonEnabled()` - Check form validity
  - `tapSelectLogoButton()` - Open logo picker

### LogoSelectionPageObject
- **Responsibilities**: Logo search and selection
- **Key Methods**:
  - `searchForLogo(query)` - Search logos
  - `selectLogoByIndex(index)` - Pick specific logo
  - `tapConfirmButton()` - Confirm selection

### CardDetailPageObject
- **Responsibilities**: Card details view and actions
- **Key Methods**:
  - `verifyCardTitle(title)` - Verify displayed title
  - `verifyCodeVisible()` - Check barcode/QR rendering
  - `verifyActionButtonsVisible()` - Check edit/share/delete

## 🚀 Running Tests

### All Integration Tests
```bash
flutter test integration_test/add_card_flows_test.dart
```

### Specific Test Case
```bash
flutter test integration_test/add_card_flows_test.dart -k "manual add card flow"
```

### On Device/Emulator (Android)
```bash
# Make sure Android emulator is running
flutter drive --target=integration_test/add_card_flows_test.dart
```

### Headless on CI/CD
```bash
# Set up Android emulator in headless mode
flutter drive \
  --target=integration_test/add_card_flows_test.dart \
  --headless \
  --verbose
```

### Generate Coverage Report
```bash
flutter test integration_test/ --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 🛠️ Test Helpers

### SetupIntegrationTestEnvironment()
- Initializes Flutter testing framework
- Mocks SharedPreferences for settings
- Initializes AppSettings singleton

### TestCardDataHelper
- Provides pre-configured test data:
  - `getValidQRCodeData()` - QR code test data
  - `getValidBarcodeData()` - Barcode test data
  - `getValidCustomCardData()` - Custom card builder

### TestSyncHelper
- Synchronization utilities:
  - `waitForPageTransition()` - Wait for navigation animations
  - `waitForSnackBarToDismiss()` - Wait for notifications
  - `waitForFinder()` - Retry finder with timeout

### TestErrorHandler
- Error verification:
  - `verifySnackBarMessage()` - Check error notifications
  - `verifyDialogMessage()` - Check dialog content
  - `dismissSnackBar()` - Wait and dismiss notifications

## ✅ Android-Specific Validations

All tests validate Android-specific behaviors:

| Behavior | Test | Validation |
|----------|------|-----------|
| Back Button Handling | Cancel flows | Navigation stack correct |
| Keyboard Show/Hide | Form input | Input rendering, field visibility |
| Device Rotation | (Extended tests) | State preservation across rotations |
| Screen Density | Card Preview | Proper scaling (hdpi, xhdpi, xxhdpi) |
| Multiple Density Rendering | Logo Grid | Performance on varied screens |

Future golden tests will validate consistent visual rendering across densities.

## 📊 Test Execution Timeline

| Phase | Duration | Action |
|-------|----------|--------|
| Setup | ~2s | Initialize app and environment |
| Flow 1 | ~8s | Complete manual QR code flow |
| Flow 2 | ~5s | Barcode type selection |
| Flow 3-9 | ~40s | Other flows (navigation, validation, etc) |
| **Total** | **~55s** | All tests complete |

## 🐛 Known Limitations & Future Improvements

### Current Limitations
1. **Camera Scanning**: Mocked/stubbed - requires ML Kit test helpers
2. **Image Scanning**: Requires test image files
3. **Settings Persists**: Uses mock SharedPreferences (resets each test)
4. **No Golden Tests**: Visual regression tests planned separately

### Future Enhancements
1. Add golden tests for card layouts across screen densities
2. Add camera/image scanning with mock ML Kit detector
3. Add animation timeline validation
4. Add performance profiling for add card flow
5. Add network error scenarios (for future cloud sync feature)

## 📝 Writing New Tests

### Template for Additional E2E Tests

```dart
testWidgets(
  'Descriptive test name following pattern',
  (WidgetTester tester) async {
    // ===== Arrange: Setup initial state =====
    await tester.pumpWidget(const MyApp());
    await TestSyncHelper.waitForPageTransition(tester);

    // ===== Act & Assert: Initial state =====
    await homePage.verifyHomePageDisplayed();

    // ===== Act: User interaction =====
    await homePage.tapAddCardFAB();

    // ===== Assert: Expected outcome =====
    await addCardEntryPage.verifyAddCardEntryPageDisplayed();

    // ===== Additional verifications as needed =====
  },
  timeout: const Timeout(Duration(seconds: 30)),
);
```

### Best Practices

✅ **DO**
- Use Page Objects for all UI interactions
- Follow AAA pattern (Arrange, Act, Assert)
- Use meaningful test names
- Add appropriate timeouts
- Verify assertions match user perspective
- Use `pumpAndSettle()` after navigation

❌ **DON'T**
- Use `sleep()` or hardcoded delays
- Directly access widgets without page objects
- Mix multiple user flows in one test
- Assert implementation details
- Ignore error cases
- Forget to clean up resources

## 🔧 CI/CD Integration

GitHub Actions workflow configured in `.github/workflows/flutter-test.yml`:

```yaml
integration_test:
  runs-on: ubuntu-latest
  strategy:
    matrix:
      api-level: [28, 31]  # Android 9, 12
  steps:
    - uses: actions/checkout@v4
    - uses: subosito/flutter-action@v2
    - uses: ReactiveCircus/android-emulator-runner@v2
      with:
        api-level: ${{ matrix.api-level }}
        script: flutter drive --target=integration_test/add_card_flows_test.dart
```

Runs on every PR and push to main/develop.

## 📖 References

- [Flutter Integration Test Docs](https://flutter.dev/docs/testing/integration-tests)
- [Flutter Test Cookbook](https://flutter.dev/docs/cookbook/testing/widget/introduction)
- [Page Object Model Pattern](https://martinfowler.com/bliki/PageObject.html)
- [E2E Testing Best Practices](https://github.com/flutter/flutter/wiki/Testing-the-engine)
