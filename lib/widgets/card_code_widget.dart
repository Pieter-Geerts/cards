// Displays the card's QR code or barcode.
import 'package:flutter/material.dart';

// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:barcode_widget/barcode_widget.dart';
import '../models/card_item.dart';

class CardCodeWidget extends StatelessWidget {
  final CardItem card;
  const CardCodeWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = card.description;
    final codeWidget = card.renderCode(size: 180, width: 180, height: 80);

    // Wrap the code widget in a container that adds a subtle background in
    // dark mode to increase contrast and readability.
    final codeContainer = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            theme.brightness == Brightness.dark
                ? theme.colorScheme.surface
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: codeWidget),
    );

    List<Widget> children = [
      codeContainer,
      if (card.is1D)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            card.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      if (description.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            description,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
    ];
    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }
}
