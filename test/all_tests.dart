import 'package:flutter_test/flutter_test.dart';

import 'database_mock_test.dart' as database_tests;
import 'home_page_test.dart' as home_page_tests;
import 'models/card_item_test.dart' as card_item_tests;
import 'models/code_renderer_test.dart' as code_renderer_tests;
import 'unit/database_helper_unit_test.dart' as unit_tests;

void main() {
  group('Database Tests', database_tests.main);
  group('Database Unit Tests', unit_tests.main);
  group('Home Page Tests', home_page_tests.main);
  group('Card Item Model Tests', card_item_tests.main);
  group('Code Renderer Tests', code_renderer_tests.main);
}
