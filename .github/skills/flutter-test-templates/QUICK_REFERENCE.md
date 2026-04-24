# Quick Reference: Flutter Test Architecture

## Test Hierarchy & When to Use Each

```
┌─────────────────────────────────────────────────────────────┐
│                    Test Pyramid                              │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│                     Integration Tests                         │  ← E2E flows on emulator
│              (integration_test/app_test.dart)                 │     (Slow, comprehensive)
│                                                               │
│ ┌────────────────────────────────────────────────────────┐  │
│ │           Widget Tests (test/widget/)                  │  │  ← UI components
│ │    (flutter_test, flutter_pump, mocktail)             │  │     (Medium speed)
│ └────────────────────────────────────────────────────────┘  │
│ ┌────────────────────────────────────────────────────────┐  │
│ │            Unit Tests (test/unit/)                     │  │  ← Business logic
│ │       (test, mockito, repository, service)            │  │     (Fast)
│ └────────────────────────────────────────────────────────┘  │
│                                                               │
│         ✅ Golden Tests (test/goldens/) - All levels         │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

| Test Type | Framework | Speed | Cost | Use For |
|-----------|-----------|-------|------|---------|
| **Unit** | test, mockito | Fast ⚡ | $1 | Business logic, validation, edge cases |
| **Widget** | flutter_test, mocktail | Medium 🚀 | $10 | UI state, interactions, rendering |
| **Integration** | integration_test | Slow 🐢 | $100+ | End-to-end user flows, Android behaviors |
| **Golden** | golden_toolkit | Medium 🚀 | $10 | Visual regression across densities |

---

## File Organization

```
cards/
├── lib/
│   ├── main.dart
│   ├── pages/
│   │   ├── login/
│   │   │   └── login_page.dart
│   │   └── home/
│   │       └── home_page.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   └── user_service.dart
│   ├── repositories/
│   │   └── user_repository.dart
│   └── widgets/
│       └── custom_card.dart
│
├── test/
│   ├── unit/                          ← Business logic tests
│   │   ├── auth_service_test.dart
│   │   └── user_repository_test.dart
│   ├── widget/                        ← UI component tests
│   │   ├── login_page_test.dart
│   │   └── custom_card_test.dart
│   ├── goldens/                       ← Visual regression tests
│   │   ├── login_golden_test.dart
│   │   ├── home_golden_test.dart
│   │   └── goldens/                   ← Generated golden images
│   │       ├── golden_login_*_phone.png
│   │       └── golden_home_*_phone.png
│   └── helpers/                       ← Mocks & utilities
│       ├── mocks.dart
│       └── test_helpers.dart
│
├── integration_test/                  ← E2E tests (runs on emulator)
│   ├── app_test.dart
│   ├── page_objects/
│   │   ├── login_page_object.dart
│   │   └── home_page_object.dart
│   └── mock_server.dart
│
├── .github/
│   ├── workflows/
│   │   └── flutter-test.yml           ← CI/CD configuration
│   ├── agents/
│   │   └── qa-flutter-android.agent.md ← This QA agent
│   └── skills/
│       └── flutter-test-templates/    ← Test templates (this skill)
│
└── pubspec.yaml                       ← Dependencies with test config
```

---

## Essential Commands

```bash
# Installation
flutter pub get
flutter pub run build_runner build  # For Mockito code generation

# Testing
flutter test                         # All unit & widget tests
flutter test --coverage             # With coverage report
flutter test test/unit/              # Specific directory
flutter test --tags=golden           # Only golden tests
flutter test --tags=golden --update-goldens  # Generate/update goldens

# Integration Testing
flutter drive --target=integration_test/app_test.dart  # On device/emulator
flutter drive --target=integration_test/app_test.dart --headless  # CI/CD mode

# Build
flutter build apk --split-per-abi    # Debug APK for testing
```

---

## Mocking Strategy by Layer

### Service Layer (mockito / mocktail)
```dart
class MockAuthService extends Mock implements AuthService {}

when(() => mockAuthService.signIn(...)).thenAnswer((_) async => true);
when(() => mockAuthService.signIn(...)).thenThrow(Exception('Error'));
```

### Repository Layer (mockito)
```dart
@GenerateMocks([UserService])
void main() {
  late MockUserService mockUserService;
  // Use generated mock...
}
```

### HTTP/Network (fake implementations)
```dart
class FakeHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    // Return mocked response
  }
}
```

---

## Coverage Targets

Target: **80%+ unit + widget coverage**, **100% critical integration paths**

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Key Constraints & Anti-Patterns

### ✅ DO
- Write tests BEFORE or WITH feature code
- Mock external dependencies (API, database, services)
- Use Page Objects in integration tests
- Test happy path + error paths + edge cases
- Tag golden tests with `@Tags(['golden'])`
- Commit golden images to version control
- Reuse test helpers and page objects

### ❌ DON'T
- Sleep/wait with `Future.delayed` — use `pumpAndSettle`, `pump(Duration)`
- Copy-paste test code — extract to helpers
- Hardcode test data — use factories or utils
- Test third-party library internals
- Create UI-only tests (test real logic)
- Skip Android-specific behaviors
- Commit generated mock files (use build_runner)

---

## Integration with GitHub Actions

The workflow in `github-actions-workflow.md` runs on every push to main/develop:

1. **Unit Tests** - `flutter test --coverage`
2. **Widget Tests** - `flutter test`
3. **Integration Tests** - `flutter drive` on Android emulator (API 28, 31)
4. **Golden Tests** - `flutter test --tags=golden`
5. **Build APK** - Only if all tests pass

---

## Example: Adding Tests to a New Feature

### Step 1: Design Tests (aligned with requirements)
```
UX: User can search for cards by name
→ Must verify:
  - Search field accepts input ✓
  - Results appear after input ✓
  - Empty results show proper state ✓
  - API error shows error message ✓
```

### Step 2: Create Unit Tests
```dart
test/unit/card_search_service_test.dart
  - searchCards returns results
  - searchCards handles empty query
  - searchCards handles API error
  - Caching works correctly
```

### Step 3: Create Widget Tests
```dart
test/widget/card_search_page_test.dart
  - Search field visible and editable
  - Results list displays correctly
  - Empty state when no results
  - Error message on failure
  - Loading indicator shows
```

### Step 4: Create Golden Tests
```dart
test/goldens/card_search_golden_test.dart
  - Empty state (phone, tablet)
  - Filled state with results (phone, tablet)
  - Error state (phone)
```

### Step 5: Create Integration Test
```dart
integration_test/search_flow_test.dart
  - Complete user flow:
    1. Open search screen
    2. Type search term
    3. View results
    4. Tap result to open detail
    5. Back to search
```

### Step 6: Run All Tests
```bash
flutter test --coverage
flutter test --tags=golden --update-goldens
flutter drive --target=integration_test/search_flow_test.dart
```

---

## Support & Troubleshooting

**Tests failing locally?**
- Run `flutter clean && flutter pub get && flutter pub run build_runner build`
- Check mock setup with `verify()`
- Use `--verbose` flag for detailed output

**Integration tests timeout on emulator?**
- Increase timeout in `flutter_test` config
- Check for `Future.delayed` instead of `pump(Duration)`
- Verify Android emulator has sufficient resources

**Golden test mismatch across machines?**
- Ensure same Flutter version on local + CI
- Check font availability (system fonts may differ)
- Use deterministic test data (no time-based, random values)

**Coverage not generated?**
- Run with `--coverage` flag explicitly
- Ensure tests use `@isTest` or are in `*_test.dart` files
- Check `lcov.info` file exists in `coverage/`
