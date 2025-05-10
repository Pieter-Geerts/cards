import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/app_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _currentLanguage;

  @override
  void initState() {
    super.initState();
    _currentLanguage = AppSettings.getLanguageCode();
    AppSettings.addStaticListener(
      _onLanguageChanged,
    ); // Listen for language changes
  }

  @override
  void dispose() {
    AppSettings.removeStaticListener(_onLanguageChanged); // Clean up listener
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) {
      // Ensure the widget is still in the tree
      setState(() {
        _currentLanguage = AppSettings.getLanguageCode();
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
          // Add more settings here
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
      default:
        return l10n.english;
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
            await AppSettings.setLanguageCodeAndNotify(
              value,
            ); // Use the static method
            // The listener _onLanguageChanged will update _currentLanguage and call setState.
            // For immediate UI update of the radio button itself before dialog pop:
            // setState(() {
            //   _currentLanguage = value;
            // });
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
        },
      ),
      onTap: () async {
        await AppSettings.setLanguageCodeAndNotify(
          languageCode,
        ); // Use the static method
        // The listener _onLanguageChanged will update _currentLanguage and call setState.
        // For immediate UI update of the radio button itself before dialog pop:
        // setState(() {
        //   _currentLanguage = languageCode;
        // });
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
    );
  }
}
