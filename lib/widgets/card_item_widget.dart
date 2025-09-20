import 'package:flutter/material.dart';

import '../models/card_item.dart';
import 'logo_avatar_widget.dart';

class CardItemWidget extends StatelessWidget {
  final CardItem card;
  final VoidCallback onTap;
  final VoidCallback onActions;

  const CardItemWidget({
    super.key,
    required this.card,
    required this.onTap,
    required this.onActions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(card.id ?? card.name + card.createdAt.toString()),
      margin: const EdgeInsets.symmetric(vertical: 14.0),
      child: Material(
        elevation: 8.0,
        borderRadius: BorderRadius.circular(20.0),
        color: Theme.of(context).cardColor,
        shadowColor:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.white24
                : Colors.black26,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.0),
          onTap: onTap,
          splashColor: Theme.of(context).colorScheme.primary.withAlpha(31),
          highlightColor: Theme.of(context).colorScheme.primary.withAlpha(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 28.0,
              horizontal: 24.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LogoAvatarWidget(
                  logoKey: card.logoPath,
                  logoIcon: null,
                  title: card.title,
                  size: 48,
                  background: Theme.of(context).cardColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (card.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          card.description,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(204),
                            fontSize: 16,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onActions,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
