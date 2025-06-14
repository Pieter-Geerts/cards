// Configuration file for app settings
// This allows the app to compile even when secrets.dart is missing (e.g., in CI)

class AppConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
}
