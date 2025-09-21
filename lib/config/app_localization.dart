import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/app_localizations.dart';

/// Centralized localization configuration for the Cards app.
/// Update this file to add supported locales and localization delegates.
class AppLocalizationConfig {
  static const supportedLocales = [
    Locale('en'),
    Locale('nl'),
    // Add more supported locales here
  ];

  static final localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}
