import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalizations l10n;
  final List<Widget> actions;

  const HomeAppBar({super.key, required this.l10n, required this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(l10n.myCards),
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
