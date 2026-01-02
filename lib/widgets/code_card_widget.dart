import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/card_item.dart';

/// A reusable white card that displays a barcode/QR code and optional logo.
class CodeCardWidget extends StatelessWidget {
  final CardItem card;
  final double? maxWidth;
  final double? maxHeight;
  final VoidCallback? onTap;
  final bool showLogo;
  final bool logoOverlay;

  const CodeCardWidget({
    Key? key,
    required this.card,
    this.maxWidth,
    this.maxHeight,
    this.onTap,
    this.showLogo = true,
    this.logoOverlay = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight =
            constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : (maxHeight ?? double.infinity);

        // Determine the effective card width (bounded by provided maxWidth)
        // and ensure we have a finite width to layout the renderer correctly.
        final cardWidth =
            (maxWidth == null)
                ? availableWidth
                : availableWidth.clamp(0.0, maxWidth!);

        // Account for horizontal padding inside the card when calculating the
        // renderer width so the renderer is visually centered within the
        // white area (padding 16 left + 16 right = 32).
        const horizontalPadding = 16.0 * 2;
        final innerWidth = math.max(0.0, cardWidth - horizontalPadding);
        final rendererWidth = card.is1D ? innerWidth * 0.95 : innerWidth * 0.85;
        final rendererSize = card.is2D ? rendererWidth : null;
        final rendererHeight =
            card.is1D ? 140.0 : (rendererSize ?? rendererWidth);

        // Limit renderer height to a fraction of the available card height
        final maxRendererHeight =
            availableHeight.isFinite
                ? math.min(rendererHeight, availableHeight * 0.6)
                : rendererHeight;

        // Ensure the card always receives a finite maxHeight. Tests and some
        // layouts provide unbounded height, which causes RenderBox layout
        // assertions when children (like Expanded) expect bounded space. We
        // fall back to a sensible default when no finite constraint is
        // available.
        final fallbackMaxHeight = 400.0;
        final effectiveMaxHeight =
            maxHeight ??
            (constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : fallbackMaxHeight);
        final cardConstraints = BoxConstraints(
          maxWidth: maxWidth ?? 900,
          maxHeight: effectiveMaxHeight,
        );

        final cardChild = Card(
          color: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Group renderer + value into a single vertically-centered
                      // block so they remain aligned relative to each other.
                      if ((maxHeight != null) || constraints.maxHeight.isFinite)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: rendererWidth,
                                  height: maxRendererHeight,
                                  child: Center(
                                    child: card.renderCode(
                                      size: rendererSize,
                                      width: rendererWidth,
                                      height: maxRendererHeight,
                                    ),
                                  ),
                                ),
                                if (card.isBarcode) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    _formatCode(card.name),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'monospace',
                                      color: theme.colorScheme.onSurface,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  if (_formatCode(card.name) != card.name)
                                    Opacity(
                                      opacity: 0.0,
                                      child: Text(
                                        card.name,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                ],
                                if (card.is2D) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    card.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          theme.brightness == Brightness.dark
                                              ? Colors.black
                                              : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  if (_formatCode(card.name) != card.name)
                                    Opacity(
                                      opacity: 0.0,
                                      child: Text(
                                        card.name,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                ],
                              ],
                            ),
                          ),
                        )
                      else
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: rendererWidth,
                                height: maxRendererHeight,
                                child: Center(
                                  child: card.renderCode(
                                    size: rendererSize,
                                    width: rendererWidth,
                                    height: maxRendererHeight,
                                  ),
                                ),
                              ),
                              if (card.isBarcode) ...[
                                const SizedBox(height: 12),
                                Text(
                                  _formatCode(card.name),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'monospace',
                                    color: theme.colorScheme.onSurface,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                if (_formatCode(card.name) != card.name)
                                  Opacity(
                                    opacity: 0.0,
                                    child: Text(
                                      card.name,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                              if (card.is2D) ...[
                                const SizedBox(height: 12),
                                Text(
                                  card.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        theme.brightness == Brightness.dark
                                            ? Colors.black
                                            : theme.colorScheme.onSurface,
                                  ),
                                ),
                                if (_formatCode(card.name) != card.name)
                                  Opacity(
                                    opacity: 0.0,
                                    child: Text(
                                      card.name,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Optional logo positioned top-left overlapping the card border
                  if (logoOverlay && showLogo && card.logoPath != null)
                    Positioned(
                      top: -28,
                      left: 16,
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Image.asset(
                            card.logoPath!,
                            fit: BoxFit.contain,
                            width: 44,
                            height: 44,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );

        // If logoAbove (logoOverlay == false), place logo above the card in a
        // non-overlapping manner.
        // Wrap the constrained card in a SizedBox with the computed width so
        // the card (and thus the renderer) is centered precisely by the
        // surrounding Center widget. This avoids subtle offsetting when the
        // parent provides more horizontal space than needed.
        final widgetTree = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!logoOverlay && showLogo && card.logoPath != null) ...[
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.transparent,
                child: ClipOval(
                  child: Image.asset(
                    card.logoPath!,
                    fit: BoxFit.contain,
                    width: 64,
                    height: 64,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: cardWidth.isFinite && cardWidth > 0 ? cardWidth : null,
              child: ConstrainedBox(
                constraints: cardConstraints,
                child: cardChild,
              ),
            ),
          ],
        );

        return Center(child: widgetTree);
      },
    );
  }
}

// Format a numeric code into groups of 4 digits for readability, e.g.
// 2292220484809 -> "2292 2204 8480 9". Non-digit characters are preserved
// and grouping applies to sequences of digits.
String _formatCode(String raw) {
  final buffer = StringBuffer();
  final digitRuns = RegExp(r"\d+").allMatches(raw);
  int lastIndex = 0;
  for (final match in digitRuns) {
    if (match.start > lastIndex) {
      buffer.write(raw.substring(lastIndex, match.start));
    }
    final digits = match.group(0) ?? '';
    final groups = <String>[];
    for (var i = 0; i < digits.length; i += 4) {
      groups.add(digits.substring(i, (i + 4).clamp(0, digits.length)));
    }
    buffer.write(groups.join(' '));
    lastIndex = match.end;
  }
  if (lastIndex < raw.length) {
    buffer.write(raw.substring(lastIndex));
  }
  return buffer.toString();
}
