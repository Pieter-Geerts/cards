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

  @override
  void initState() {
    super.initState();
    _loadCards();
    // Listen to language changes
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
    });
  }

  Future<void> _loadCards() async {
    final cards = await _dbHelper.getCards();
    setState(() {
      _cards = cards;
    });
  }

  Future<void> _addCard(CardItem card) async {
    await _dbHelper.insertCard(card);
    _loadCards();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cards Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomePage(cards: _cards, onAddCard: _addCard),
    );
  }
}
