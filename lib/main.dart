import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/database_helper.dart';
import 'l10n/app_localizations.dart';
import 'models/card_item.dart';
import 'pages/home_page.dart';
import 'utils/app_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.init(); // Initialize settings

  // Onboarding: Insert example cards on first launch
  final prefs = await SharedPreferences.getInstance();
  final hasOnboarded = prefs.getBool('hasOnboarded') ?? false;
  if (!hasOnboarded) {
    final db = DatabaseHelper();
    final now = DateTime.now();
    // Example barcode card
    await db.insertCard(
      CardItem(
        title: 'Example Loyalty Card',
        description: 'This is a sample barcode card. You can delete it.',
        name: '123456789012',
        cardType: CardType.barcode,
        createdAt: now,
        sortOrder: 0,
      ),
    );
    await prefs.setBool('hasOnboarded', true);
  }

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
        _cards[index] = card;
      });
    } else {
      // If card not found, reload all cards to be safe
      await _loadCards();
    }
  }

  Future<void> _addCard(CardItem card) async {
    // Remove example cards if user adds a real card
    if (card.title == "##DELETE_CARD_SIGNAL##" &&
        card.id == null &&
        card.sortOrder == -1) {
      // This is the delete signal, do not insert it.
      // Proceed to load cards to refresh the list.
    } else {
      // Remove all example cards if present
      final db = DatabaseHelper();
      final cards = await db.getCards();
      for (final c in cards) {
        if (c.title.startsWith('Example')) {
          if (c.id != null) await db.deleteCard(c.id!);
        }
      }
      await _dbHelper.insertCard(card);
    }
    await _loadCards();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Just Cards', // This could be localized too if needed
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
      home: HomePage(
        cards: _cards,
        onAddCard: _addCard,
        onUpdateCard: _updateCard,
      ),
    );
  }
}

// Pre-commit hook test
