# pubspec.yaml Test Configuration

Add these dev dependencies to your `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Integration Testing
  integration_test:
    sdk: flutter
  
  # Mocking & Faking
  mockito: ^6.1.6
    build_runner: ^2.4.6
  mocktail: ^1.0.3
  fake_async: ^1.3.1
  
  # Golden Testing (Visual Regression)
  golden_toolkit: ^0.15.0
  alchemist: ^0.7.0  # Alternative golden testing framework
  
  # Testing Utilities
  test: ^1.24.0
  matcher: ^0.12.15
  
  # Code Coverage
  coverage: ^7.2.2

flutter:
  uses-material-design: true

# Test Configuration
flutter_test:
  timeout: 300s  # Increase timeout for integration tests on emulator
```

## Additional Configuration Files

### build.yaml (for Mockito code generation)

Create `build.yaml` in your project root:

```yaml
targets:
  $default:
    builders:
      mockito|precompile:
        generate_for:
          - 'test/**_test.dart'
          - 'lib/**/*.dart'
```

### flutter_test Configuration

In `test/flutter_test_config.dart`:

```dart
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable() async {
  // Set custom timeouts for integration tests
  const timeout = Timeout(Duration(seconds: 60));
  testWidgets('example', (WidgetTester tester) async {
    // Your test here
  }, timeout: timeout);
}
```

## Common Dependencies Explanation

| Package | Purpose | Usage |
|---------|---------|-------|
| `integration_test` | Flutter SDK integration test framework | E2E testing on device/emulator |
| `mockito` | Mock generation for testing | Unit/widget tests with dependency mocking |
| `mocktail` | No-code-gen mocking | Simpler mocking without build_runner |
| `golden_toolkit` | Golden testing utilities | Golden image generation with multiple screen sizes |
| `alchemist` | Alternative golden framework | Widget tree comparison + visual regression |
| `test` | Dart test framework | Pure Dart unit tests |
| `coverage` | Coverage reporting | CI/CD coverage metrics |

## Installation Command

```bash
flutter pub get
flutter pub run build_runner build  # For Mockito
```
