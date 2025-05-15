import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'helpers/database_helper.dart';
import 'models/card_item.dart';
import 'pages/home_page.dart';
import 'utils/app_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.init(); // Initialize settings
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<CardItem> _cards = [];
  Locale _locale = Locale(AppSettings.getLanguageCode());
  ThemeMode _themeMode = _getThemeModeFromString(AppSettings.getThemeMode());

  static ThemeMode _getThemeModeFromString(String themeModeString) {
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCards();
    // Listen to settings changes
    AppSettings.addStaticListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    AppSettings.removeStaticListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {
      _locale = Locale(AppSettings.getLanguageCode());
      _themeMode = _getThemeModeFromString(AppSettings.getThemeMode());
    });
  }

  Future<void> _loadCards() async {
    final cards = await _dbHelper.getCards();
    if (mounted) {
      // Check if the widget is still in the tree
      setState(() {
        _cards = cards;
      });
    }
  }

  Future<void> _addCard(CardItem card) async {
    // Check if the card is the delete signal
    if (card.title == "##DELETE_CARD_SIGNAL##" &&
        card.id == null &&
        card.sortOrder == -1) {
      // This is the delete signal, do not insert it.
      // Proceed to load cards to refresh the list.
    } else {
      // This is a genuine new card, insert it.
      await _dbHelper.insertCard(card);
    }
    await _loadCards(); // Reload cards to reflect changes (addition or post-deletion refresh)
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cards Demo', // This could be localized too if needed
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomePage(cards: _cards, onAddCard: _addCard),
    );
  }
}
