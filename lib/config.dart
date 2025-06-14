// Configuration file that handles secrets gracefully
// This allows the app to compile even when secrets.dart is missing (e.g., in CI)

// Default configuration when secrets are not available
const String _defaultLogoDevApiKey = '';

// Try to get the API key from environment or use default
const String logoDevApiKey = String.fromEnvironment('LOGODEV_API_KEY', defaultValue: _defaultLogoDevApiKey);

class AppConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const String logoDevApiKey = String.fromEnvironment('LOGODEV_API_KEY', defaultValue: _defaultLogoDevApiKey);
}
