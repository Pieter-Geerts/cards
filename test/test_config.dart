import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_helpers.dart' as helpers;

/// Global test configuration loaded by the test runner before other tests.
/// Ensures the Flutter binding and test SharedPreferences are initialized
/// so tests that use platform channels or SharedPreferences will not fail
/// with binding-not-initialized errors.
void main() {
  // Ensure binding is initialized early
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await helpers.setupTestEnvironment();
  });
}
