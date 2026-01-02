import 'package:flutter/material.dart';

import 'config/app_localization.dart';
import 'config/app_theme.dart';
import 'models/card_item.dart';
import 'pages/home_page.dart';
import 'repositories/card_repository_interface.dart';
import 'repositories/sqlite_card_repository.dart';
import 'services/error_handling_service.dart';
import 'utils/app_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Just Cards',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizationConfig.localizationsDelegates,
      supportedLocales: AppLocalizationConfig.supportedLocales,
      home: const AppInitializer(),
    );
  }
}

/// Handles app initialization with splash screen
///
/// This widget manages:
/// - AppSettings initialization
/// - Repository setup
/// - Locale and theme configuration
/// - Error handling and fallback UI
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late final _initializationFuture = _initializeApp();

  /// Initialize all required components for the app
  ///
  /// Sequence:
  /// 1. Initialize AppSettings (locale, theme preferences)
  /// 2. Create and initialize repository
  /// 3. Load initial data (cards)
  /// 4. Return initialized state for the main app
  Future<_AppState> _initializeApp() async {
    try {
      // Step 1: Initialize settings (locale, theme)
      await AppSettings.init();

      final locale = Locale(AppSettings.getLanguageCode());
      final themeMode = _getThemeModeFromString(AppSettings.getThemeMode());

      // Step 2: Initialize repository
      final cardRepository = SqliteCardRepository();

      // Step 3: Load initial data
      final cardsResult = await cardRepository.getCards();

      final cards = cardsResult.fold((failure) {
        // Log error but don't crash
        ErrorHandlingService.instance.handleError(
          failure,
          StackTrace.current,
          context: 'AppInitializer: Failed to load cards',
        );
        return <CardItem>[]; // Return empty list on error
      }, (cards) => cards);

      return _AppState(
        locale: locale,
        themeMode: themeMode,
        cardRepository: cardRepository,
        cards: cards,
        error: null,
      );
    } catch (error, stackTrace) {
      ErrorHandlingService.instance.handleError(
        error,
        stackTrace,
        context: 'AppInitializer: Initialization failed',
        isFatal: true,
      );

      // Return error state for fallback UI
      return _AppState(
        locale: const Locale('en'),
        themeMode: ThemeMode.system,
        cardRepository: null,
        cards: const [],
        error: error is Exception ? error : Exception(error.toString()),
      );
    }
  }

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
  Widget build(BuildContext context) {
    return FutureBuilder<_AppState>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        // Show splash screen while initializing
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _SplashScreen();
        }

        // Handle initialization errors
        if (snapshot.hasError) {
          return _ErrorScreen(error: snapshot.error.toString());
        }

        // Build app with initialized state
        if (snapshot.hasData) {
          final appState = snapshot.data!;

          // Show error fallback if initialization partially failed
          if (appState.error != null) {
            return _ErrorFallbackScreen(
              error: appState.error!,
              onRetry: () {
                setState(() {
                  // Re-run initialization by resetting the future
                });
              },
            );
          }

          // All initialized successfully, show main app
          return _InitializedApp(state: appState);
        }

        return _SplashScreen();
      },
    );
  }
}

/// Lightweight splash screen shown during initialization
///
/// Displays:
/// - App logo/icon
/// - Loading indicator
/// - Initialization status message
class _SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Icon(
              Icons.credit_card,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            // Loading indicator
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            // Status text
            Text(
              'Initializing app...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Error screen when initialization fails completely
class _ErrorScreen extends StatelessWidget {
  final String error;

  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              'Initialization Error',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fallback error UI when partial initialization fails
///
/// Shows error message and allows retry
class _ErrorFallbackScreen extends StatelessWidget {
  final Exception error;
  final VoidCallback onRetry;

  const _ErrorFallbackScreen({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_outlined, size: 64, color: Colors.orange),
            const SizedBox(height: 24),
            Text(
              'Initialization Warning',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main app widget after successful initialization
///
/// This widget replaces [MyApp] and handles:
/// - Theme and locale from AppSettings
/// - Repository and card state management
/// - Settings change notifications
class _InitializedApp extends StatefulWidget {
  final _AppState state;

  const _InitializedApp({required this.state});

  @override
  State<_InitializedApp> createState() => _InitializedAppState();
}

class _InitializedAppState extends State<_InitializedApp> {
  late Locale _locale;
  late ThemeMode _themeMode;
  late final CardRepository _cardRepository;
  late List<CardItem> _cards;

  @override
  void initState() {
    super.initState();
    _locale = widget.state.locale;
    _themeMode = widget.state.themeMode;
    _cardRepository = widget.state.cardRepository!;
    _cards = widget.state.cards;

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

  Future<void> _loadCards() async {
    final res = await _cardRepository.getCards();
    if (mounted) {
      res.fold(
        (failure) {
          final message = failure.message;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
        (cards) {
          setState(() => _cards = cards);
        },
      );
    }
  }

  Future<void> _updateCard(CardItem card) async {
    final index = _cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      setState(() {
        _cards = List.from(_cards);
        _cards[index] = card;
      });
    } else {
      await _loadCards();
    }
  }

  Future<void> _addCard(CardItem card) async {
    final res = await _cardRepository.insertCard(card);
    if (mounted) {
      res.fold(
        (failure) {
          final message = failure.message;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
        (_) async {
          await _loadCards();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Just Cards',
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

/// Container for initialized app state
class _AppState {
  final Locale locale;
  final ThemeMode themeMode;
  final CardRepository? cardRepository;
  final List<CardItem> cards;
  final Exception? error;

  _AppState({
    required this.locale,
    required this.themeMode,
    required this.cardRepository,
    required this.cards,
    required this.error,
  });
}
