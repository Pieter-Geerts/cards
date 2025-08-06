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
- **Note**: Some integration tests are marked as 'slow' and may take several minutes

## Test Execution

### Running All Tests

```bash
flutter test
```

### Running Fast Tests Only (Excludes Slow Integration Tests)

```bash
flutter test --exclude-tags=slow
```

### Running Only Slow Tests

```bash
flutter test --tags=slow
```

### Running Only Integration Tests

```bash
flutter test --tags=integration
```

### Running Fast Integration Tests Only

```bash
flutter test --tags=fast
```

### Running Unit Tests Only

```bash
flutter test test/unit/
```

## Test Performance Optimization

### Fast vs Slow Integration Tests

To improve development workflow, integration tests are categorized into two types:

#### Fast Integration Tests (`tags: ['integration', 'fast']`)

- **Execution Time**: Seconds
- **Approach**: Use mocks and simple test widgets
- **Purpose**: Quick feedback during development
- **Example**: `test/integration/edit_card_ui_update_test.dart`

```dart
// Fast test pattern using mocks
testWidgets('component updates data through callback', (tester) async {
  await tester.pumpWidget(TestableWidget(
    child: TestCardEditWidget(card: testCard, onSave: callback),
  ));
  // Test individual component behavior
});
```

#### Slow Integration Tests (`tags: ['integration', 'slow', 'e2e']`)

- **Execution Time**: Minutes (3+ minutes)
- **Approach**: Real app with actual database
- **Purpose**: End-to-end validation before release
- **Example**: `test/integration/edit_card_ui_update_slow_test.dart`

```dart
// Slow test pattern using real app
testWidgets('complete user workflow', (tester) async {
  await tester.pumpWidget(const MyApp());
  // Full user interaction with real database
});
```

### Performance Benefits

The fast test approach provides:

- ✅ **10x faster execution** (seconds vs minutes)
- ✅ **No database setup overhead**
- ✅ **Predictable test data**
- ✅ **Better development feedback loop**

### Recommended Workflow

1. **During Development**: Run fast tests only

   ```bash
   flutter test --exclude-tags=slow
   ```

2. **Before Committing**: Run fast tests + unit tests

   ```bash
   flutter test test/unit/ && flutter test --tags=fast
   ```

3. **Before Release**: Run complete test suite

   ```bash
   flutter test
   ```

### Pre-commit Hook

The pre-commit hook runs only fast unit tests (`test/unit/` and `test/mocks/`) to keep commit times reasonable. Full integration tests should be run manually or in CI.

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
