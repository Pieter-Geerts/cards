import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../utils/app_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _currentLanguage;
  late String _currentThemeMode; // Add state for current theme mode

  @override
  void initState() {
    super.initState();
    _currentLanguage = AppSettings.getLanguageCode();
    _currentThemeMode = AppSettings.getThemeMode(); // Initialize theme mode
    AppSettings.addStaticListener(
      _onSettingsChanged, // Combined listener for both language and theme
    );
  }

  @override
  void dispose() {
    AppSettings.removeStaticListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) {
      setState(() {
        _currentLanguage = AppSettings.getLanguageCode();
        _currentThemeMode = AppSettings.getThemeMode(); // Update theme mode
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.language),
            subtitle: Text(_getLanguageName(_currentLanguage, l10n)),
            trailing: const Icon(Icons.language),
            onTap: () => _showLanguageSelector(context),
          ),
          ListTile(
            // Add ListTile for Theme selection
            title: Text(l10n.theme),
            subtitle: Text(_getThemeModeName(_currentThemeMode, l10n)),
            trailing: _getThemeModeIcon(_currentThemeMode),
            onTap: () => _showThemeModeSelector(context),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String languageCode, AppLocalizations l10n) {
    switch (languageCode) {
      case 'en':
        return l10n.english;
      case 'es':
        return l10n.spanish;
      case 'nl':
        return l10n.dutch;
      default:
        return l10n.english;
    }
  }

  String _getThemeModeName(String themeMode, AppLocalizations l10n) {
    switch (themeMode) {
      case 'light':
        return l10n.light;
      case 'dark':
        return l10n.dark;
      case 'system':
      default:
        return l10n.system;
    }
  }

  Icon _getThemeModeIcon(String themeMode) {
    switch (themeMode) {
      case 'light':
        return const Icon(Icons.wb_sunny);
      case 'dark':
        return const Icon(Icons.nightlight_round);
      case 'system':
      default:
        return const Icon(Icons.settings_brightness);
    }
  }

  void _showLanguageSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(context, 'en', l10n.english),
              _buildLanguageOption(context, 'es', l10n.spanish),
              _buildLanguageOption(context, 'nl', l10n.dutch), // Add this line
            ],
          ),
        );
      },
    );
  }

  void _showThemeModeSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.selectTheme),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeModeOption(
                context,
                'light',
                l10n.light,
                Icons.wb_sunny,
              ),
              _buildThemeModeOption(
                context,
                'dark',
                l10n.dark,
                Icons.nightlight_round,
              ),
              _buildThemeModeOption(
                context,
                'system',
                l10n.system,
                Icons.settings_brightness,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String languageCode,
    String languageName,
  ) {
    return ListTile(
      title: Text(languageName),
      leading: Radio<String>(
        value: languageCode,
        groupValue: _currentLanguage,
        onChanged: (value) async {
          if (value != null) {
            await AppSettings.setLanguageCodeAndNotify(value);
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
        },
      ),
      onTap: () async {
        await AppSettings.setLanguageCodeAndNotify(languageCode);
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _buildThemeModeOption(
    BuildContext context,
    String themeModeValue,
    String themeModeName,
    IconData icon,
  ) {
    return ListTile(
      title: Text(themeModeName),
      leading: Icon(icon), // Use a specific icon for the radio button
      trailing: Radio<String>(
        value: themeModeValue,
        groupValue: _currentThemeMode,
        onChanged: (value) async {
          if (value != null) {
            await AppSettings.setThemeModeAndNotify(value);
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
        },
      ),
      onTap: () async {
        await AppSettings.setThemeModeAndNotify(themeModeValue);
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
    );
  }
}
