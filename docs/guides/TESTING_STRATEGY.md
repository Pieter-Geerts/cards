# Flutter Testing Strategy for Cards App

This document outlines the testing strategy for the Cards app, focusing on using mocks to ensure tests run quickly and reliably.

## Test Structure

Our tests should be organized into the following categories:

1. **Unit Tests**

   - Model tests
   - Utility function tests
   - Service layer tests

2. **Widget Tests**

   - Individual widget tests
   - Page component tests

3. **Integration Tests**
   - End-to-end flows

## Mocking Strategy

### Database Layer

- Use the `MockDatabaseHelper` instead of real database operations
- Simulate database operations in memory
- Test all CRUD operations using this mock

### Platform Services

- Use `PlatformMocks` to mock all platform channel interactions
- This includes:
  - Screen brightness
  - Path provider
  - File selector
  - Share functionality

### Other Services

- Create dedicated mock classes for any additional services
- Use Mockito annotations to generate mock classes where appropriate

## Test Execution Guidelines

1. All tests should run without hitting actual databases or external services
2. Tests should be independent and not rely on the order of execution
3. Use setUp/tearDown for test initialization and cleanup
4. Keep test files focused on specific functionality

## Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

## Suggested Improvements

### 1. Generate Mockito Mocks

For more complex classes, use the Mockito code generation:

```dart
// In a file like test/mocks/mocks.dart
@GenerateMocks([YourClass])
void main() {}

// Then run:
// flutter pub run build_runner build
```

### 2. Group Related Tests

Group related tests together using the `group` function:

```dart
group('CardItem Tests', () {
  test('should create card correctly', () {});
  test('should serialize to JSON', () {});
  test('should deserialize from JSON', () {});
});
```

### 3. Use Test Fixtures

For complex test data, create fixtures:

```dart
// In test/fixtures/card_fixtures.dart
final testCards = [
  CardItem(...),
  CardItem(...),
];

// In tests
import 'fixtures/card_fixtures.dart';
```

## Next Steps

1. Update existing tests to use the mock classes
2. Create additional mock classes as needed
3. Ensure all tests run quickly without external dependencies
