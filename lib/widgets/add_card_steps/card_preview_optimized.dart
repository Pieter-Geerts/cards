import 'package:cards/widgets/logo_avatar_widget.dart';
import 'package:flutter/material.dart';

class CardPreviewOptimized extends StatelessWidget {
  final String? logoPath;
  final String title;
  final String description;
  final double logoSize;
  final Color? background;

  const CardPreviewOptimized({
    Key? key,
    required this.logoPath,
    required this.title,
    required this.description,
    this.logoSize = 64,
    this.background,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          LogoAvatarWidget(
            logoKey: logoPath,
            title: title,
            size: logoSize,
            background: background,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
