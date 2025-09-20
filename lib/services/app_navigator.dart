import 'package:flutter/material.dart';

import '../pages/logo_selection_page.dart';

/// Centralized navigation manager for better routing and performance
/// Implements page caching and optimized transitions
class AppNavigator {
  static final AppNavigator _instance = AppNavigator._internal();
  static AppNavigator get instance => _instance;

  AppNavigator._internal();

  // Cache for page instances to avoid rebuilds
  final Map<String, Widget> _pageCache = {};

  // Navigation context for global access
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  BuildContext? get context => navigatorKey.currentContext;

  /// Navigate to logo selection page with optimized transition
  Future<IconData?> pushLogoSelection({
    required String cardTitle,
    IconData? currentLogo,
    String? cardId,
  }) async {
    if (context == null) return null;

    // Use optimized page transition for smoother experience
    final result = await Navigator.of(context!).push<IconData?>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return LogoSelectionPage(
            cardTitle: cardTitle,
            currentLogo: currentLogo,
            cardId: cardId,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Optimized slide transition
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
      ),
    );

    return result;
  }

  /// Navigate to logo selection with modal presentation
  Future<IconData?> showLogoSelectionModal({
    required String cardTitle,
    IconData? currentLogo,
    String? cardId,
  }) async {
    if (context == null) return null;

    return showModalBottomSheet<IconData?>(
      context: context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: LogoSelectionPage(
              cardTitle: cardTitle,
              currentLogo: currentLogo,
              cardId: cardId,
            ),
          ),
    );
  }

  /// Pop current route with result
  void pop<T>([T? result]) {
    if (context != null) {
      Navigator.of(context!).pop(result);
    }
  }

  /// Check if can pop current route
  bool canPop() {
    return context != null && Navigator.of(context!).canPop();
  }

  /// Clear page cache to free memory
  void clearCache() {
    _pageCache.clear();
  }
}
