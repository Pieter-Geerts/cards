import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/simple_icons_mapping.dart';

/// Widget to display either a brand logo (SimpleIcons), SVG/file, or initials fallback.
class LogoAvatarWidget extends StatelessWidget {
  final String? logoKey;
  final IconData? logoIcon; // Direct IconData support
  final String? title;
  final double size;
  final Color? background;

  const LogoAvatarWidget({
    super.key,
    this.logoKey,
    this.logoIcon,
    this.title,
    this.size = 48,
    this.background,
  });

  /// Helper method to build initials fallback
  Widget _buildInitials(BuildContext context) {
    String initials = '';
    if (title != null && title!.isNotEmpty) {
      final words = title!.trim().split(RegExp(r'\\s+'));
      if (words.length == 1) {
        initials =
            words[0].length >= 2
                ? words[0].substring(0, 2).toUpperCase()
                : words[0].toUpperCase();
      } else if (words.length > 1) {
        initials = words[0][0].toUpperCase() + words[1][0].toUpperCase();
      }
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final avatarBackground =
        background ??
        (isDark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surface);
    final textColor = theme.colorScheme.onSurface;
    final iconColor = theme.colorScheme.onSurface.withAlpha(179);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: avatarBackground,
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).dividerColor.withAlpha(60)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child:
          initials.isNotEmpty
              ? Text(
                initials,
                key: const Key('logo-initials'),
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              )
              : Icon(Icons.credit_card, size: size * 0.6, color: iconColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final avatarBackground =
        background ??
        (isDark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surface);

    // Direct IconData support (highest priority)
    if (logoIcon != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: avatarBackground,
          shape: BoxShape.circle,
          border: Border.all(color: theme.dividerColor.withAlpha(60)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withAlpha(12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          logoIcon,
          // Use onSurface for readable contrast on both themes
          color: theme.colorScheme.onSurface,
          size: size * 0.7,
        ),
      );
    }

    // Simple Icon identifier support (e.g., "simple_icon:github")
    if (logoKey != null && logoKey!.startsWith('simple_icon:')) {
      final icon = SimpleIconsMapping.getIcon(logoKey!);
      if (icon != null) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: avatarBackground,
            shape: BoxShape.circle,
            border: Border.all(color: theme.dividerColor.withAlpha(60)),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withAlpha(12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: theme.colorScheme.onSurface,
            size: size * 0.7,
          ),
        );
      }
    }

    // File path support for backward compatibility (SVG/image files)
    if (logoKey != null &&
        logoKey!.isNotEmpty &&
        !logoKey!.startsWith('simple_icon:')) {
      try {
        final file = File(logoKey!);
        if (file.existsSync()) {
          if (logoKey!.toLowerCase().endsWith('.svg')) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: avatarBackground,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).dividerColor.withAlpha(60),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withAlpha(12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: ClipOval(
                child: SvgPicture.file(
                  file,
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                ),
              ),
            );
          } else {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: avatarBackground,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).dividerColor.withAlpha(60),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withAlpha(12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                image: DecorationImage(
                  image: FileImage(file),
                  fit: BoxFit.cover,
                ),
              ),
            );
          }
        }
      } catch (_) {
        // If any error occurs, fallback to initials
      }
    }

    // Initials fallback
    return _buildInitials(context);
  }
}
