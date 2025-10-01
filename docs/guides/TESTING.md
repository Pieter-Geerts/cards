# Testing Guide — Strategy, Coverage, and How-To

This merged guide consolidates test strategy, practical test running instructions,
and coverage notes. It replaces `TESTING_GUIDE.md`, `TESTING_STRATEGY.md`, and
`TEST_COVERAGE.md` to prevent duplication and drift.

## Overview

We use a three-level testing pyramid:

- Unit tests: model and utility functions
- Widget tests: UI components and pages
- Integration tests: end-to-end flows

All tests live under `test/` and follow the AAA pattern (Arrange, Act, Assert).

## Mocking and Isolation

- Use Mockito or small in-memory fakes for databases and services.
- Platform interactions (screen brightness, path provider, share) must be mocked
  in widget tests so tests run reliably and quickly.
- Keep async work inside `tester.runAsync` when creating temporary files.

## Test Organization

- `test/models/` — model and enum tests
- `test/widgets/` — widget tests
- `test/integration/` — integration tests (full flows)
- `test/mocks/` and `test/helpers/` — supporting test utilities

## Running tests

Run all tests:

```bash
flutter test
```

Run with coverage:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

Run a single test file:

```bash
flutter test test/models/card_item_test.dart
```

## Coverage & Critical Paths

Focus coverage on core architecture and user-facing flows:

- CardItem model and CardType enum
- Code renderers and factory system
- Add/Edit card pages and validation
- Database migration tests

Refer to `TEST_COVERAGE.md` in the backup for a detailed mapping of tests to features.

## Best Practices

- Keep tests small and isolated
- Use fixtures for complex test data
- Regenerate Mockito mocks via build_runner where needed

## CI Integration

- Ensure CI runs all unit and widget tests on PRs
- Integration tests that require device features should be gated or run in a
  dedicated job with a device/emulator environment

## Next Steps

- Remove legacy testing docs (done)
- Keep `docs/guides/TESTING.md` as the single source of truth
