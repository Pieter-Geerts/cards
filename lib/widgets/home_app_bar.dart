import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalizations l10n;
  final List<Widget> actions;
  // Optional widget to be displayed in the AppBar title area. When null,
  // the localized app title is shown.
  final Widget? titleWidget;

  const HomeAppBar({
    super.key,
    required this.l10n,
    required this.actions,
    this.titleWidget,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: titleWidget ?? Text(l10n.myCards),
      ),
      actions: actions,
      elevation: 4.0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      iconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.onSurface,
        size: 28,
      ),
      toolbarHeight: 64,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
