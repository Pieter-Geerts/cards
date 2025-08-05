import 'package:flutter_test/flutter_test.dart';

import 'add_card_page_test.dart' as add_card_tests;
import 'database_mock_test.dart' as database_tests;
import 'home_page_test.dart' as home_page_tests;
import 'integration/add_card_flow_test.dart' as integration_tests;
import 'models/card_item_test.dart' as card_item_tests;
import 'models/code_renderer_test.dart' as code_renderer_tests;

/// This file imports and runs all tests in the codebase.
/// Run with: flutter test test/all_tests.dart

void main() {
  group('Database Tests', database_tests.main);
  group('Add Card Page Tests', add_card_tests.main);
  group('Home Page Tests', home_page_tests.main);
  group('Card Item Model Tests', card_item_tests.main);
  group('Code Renderer Tests', code_renderer_tests.main);
  group('Integration Tests', integration_tests.main);
}
