// Displays card title, logo, and type.
import 'package:flutter/material.dart';

import '../models/card_item.dart';
import 'logo_avatar_widget.dart';

class CardInfoWidget extends StatelessWidget {
  final CardItem card;
  const CardInfoWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        LogoAvatarWidget(
          logoKey: card.logoPath,
          logoIcon: null,
          title: card.title,
          size: 28,
          background: Colors.transparent,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            card.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
