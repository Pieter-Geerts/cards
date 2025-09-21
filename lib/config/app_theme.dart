import 'package:flutter/material.dart';

/// Centralized theme data for the Cards app.
/// Update this file to change global colors, typography, and Material 3 settings.
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    brightness: Brightness.light,
    fontFamily: 'Roboto',
    // Add more customizations as needed
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    brightness: Brightness.dark,
    fontFamily: 'Roboto',
    // Add more customizations as needed
  );
}
