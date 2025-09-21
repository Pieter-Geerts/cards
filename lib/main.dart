import 'package:flutter/material.dart';

import 'config/app_localization.dart';
import 'config/app_theme.dart';
import 'helpers/database_helper.dart';
// import 'l10n/app_localizations.dart';
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

  Future<void> _updateCard(CardItem card) async {
    final index = _cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      setState(() {
        // Create a new list instance to ensure didUpdateWidget detects the change
        _cards = List.from(_cards);
        _cards[index] = card;
      });
    } else {
      // If card not found, reload all cards to be safe
      await _loadCards();
    }
  }

  Future<void> _addCard(CardItem card) async {
    if (card.title == "##DELETE_CARD_SIGNAL##" &&
        card.id == null &&
        card.sortOrder == -1) {
      // This is the delete signal, do not insert it.
      // Proceed to load cards to refresh the list.
    } else {
      await _dbHelper.insertCard(card);
    }
    await _loadCards();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Just Cards', // This could be localized too if needed
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: AppLocalizationConfig.localizationsDelegates,
      supportedLocales: AppLocalizationConfig.supportedLocales,
      home: HomePage(
        cards: _cards,
        onAddCard: _addCard,
        onUpdateCard: _updateCard,
      ),
    );
  }
}

// Pre-commit hook test
