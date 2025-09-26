import 'package:cards/widgets/logo_avatar_widget.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class CardPreviewWidget extends StatelessWidget {
  final String? logoPath;
  final String title;
  final String description;
  final double logoSize;
  final Color? background;

  const CardPreviewWidget({
    super.key,
    required this.logoPath,
    required this.title,
    required this.description,
    this.logoSize = 64,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        children: [
          LogoAvatarWidget(
            logoKey: logoPath,
            title: title,
            size: logoSize,
            background: background ?? Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            title.isNotEmpty
                ? title
                : AppLocalizations.of(context).cardTitleFallback,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
        ],
      ),
    );
  }
}
