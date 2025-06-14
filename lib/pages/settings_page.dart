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
  late String _currentThemeMode; 

  @override
  void initState() {
    super.initState();
    _currentLanguage = AppSettings.getLanguageCode();
    _currentThemeMode = AppSettings.getThemeMode();
    AppSettings.addStaticListener(
      _onSettingsChanged, 
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
            subtitle: Text(_getCurrentLanguageDisplay(l10n)),
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

  String _getCurrentLanguageDisplay(AppLocalizations l10n) {
    final hasSetLanguage = AppSettings.getHasSetLanguage();
    final currentLanguage = _currentLanguage;
    final deviceLanguage = AppSettings.getDeviceLanguage();
    
    if (!hasSetLanguage && currentLanguage == deviceLanguage) {
      return '${l10n.deviceLanguage} (${_getLanguageName(currentLanguage, l10n)})';
    } else {
      return _getLanguageName(currentLanguage, l10n);
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
              // Device Language option
              _buildLanguageOption(
                context, 
                AppSettings.getDeviceLanguage(), 
                '${l10n.deviceLanguage} (${_getLanguageName(AppSettings.getDeviceLanguage(), l10n)})',
                isDeviceLanguage: true,
              ),
              const Divider(),
              _buildLanguageOption(context, 'en', l10n.english),
              _buildLanguageOption(context, 'es', l10n.spanish),
              _buildLanguageOption(context, 'nl', l10n.dutch),
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
    String languageName, {
    bool isDeviceLanguage = false,
  }) {
    return ListTile(
      title: Text(languageName),
      leading: Radio<String>(
        value: languageCode,
        groupValue: _currentLanguage,
        onChanged: (value) async {
          if (value != null) {
            if (isDeviceLanguage) {
              await AppSettings.resetToDeviceLanguage();
            } else {
              await AppSettings.setLanguageCodeAndNotify(value);
            }
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
        },
      ),
      onTap: () async {
        if (isDeviceLanguage) {
          await AppSettings.resetToDeviceLanguage();
        } else {
          await AppSettings.setLanguageCodeAndNotify(languageCode);
        }
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
