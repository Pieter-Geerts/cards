# Test Structure and Best Practices

This document outlines the structure and best practices for tests in the Cards app.

## Test Types

### Unit Tests

Located in the `test/` directory, focusing on individual classes and functions:

- `test/models/` - Tests for model classes
- `test/utils/` - Tests for utility functions

### Widget Tests

Located in the `test/` directory, focusing on UI components:

- Testing individual widgets
- Testing screens and user interactions

### Integration Tests

Located in `test/integration/`, testing end-to-end flows:

- Complete user journeys
- Cross-feature interactions

## Mock Infrastructure

### Mock Classes

We use several mock classes to isolate tests:

1. **MockCardRepository**

   - Located in `test/mocks/mock_card_repository.dart`
   - In-memory implementation of card storage
   - Used to test database operations without actual database

2. **MockNavigatorObserver**

   - Generated with Mockito
   - Used to verify navigation between screens

3. **PlatformMocks**
   - Located in `test/mocks/platform_mocks.dart`
   - Mocks platform channels for native functionality

### Test Helpers

Located in `test/helpers/`:

1. **TestableWidget**

   - Wrapper for testing widgets with standard configuration
   - Provides localization and navigation observers

2. **setupTestEnvironment()**

   - Initializes the test environment
   - Sets up platform mocks and shared preferences

3. **generateSampleCards()**
   - Creates sample card data for testing

## Best Practices

### Test Organization

1. **Use the AAA pattern**:

   - **Arrange**: Set up test data and conditions
   - **Act**: Perform the action being tested
   - **Assert**: Verify the expected outcome

2. **Group related tests**:
   ```dart
   group('CardItem', () {
     test('should create with default values', () {...});
     test('should create with specified values', () {...});
   });
   ```

### Test Isolation

1. **Reset state between tests**:

   - Use `setUp()` and `tearDown()` to initialize and clean up
   - Don't share state between tests

2. **Mock external dependencies**:
   - Use mock objects for databases, APIs, etc.
   - Test components in isolation

### Test Coverage

1. **Aim for high coverage**:

   - Run tests with coverage: `flutter test --coverage`
   - Generate coverage report: `genhtml coverage/lcov.info -o coverage/html`

2. **Focus on critical paths**:
   - Ensure core functionality is well-tested
   - Prioritize testing user-facing features

## Running Tests

### Run All Tests

```bash
flutter test
```

### Run Specific Tests

```bash
flutter test test/models/card_item_test.dart
```

### Run with Coverage

```bash
flutter test --coverage
```

### Run Master Test File

```bash
flutter test test/all_tests.dart
```

## CI Integration

Our CI pipeline runs all tests on every pull request and commit to the main branch.

1. Tests must pass before merging
2. Coverage reports are generated and tracked
3. Performance benchmarks are monitored
