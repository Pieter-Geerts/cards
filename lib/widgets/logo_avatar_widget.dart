import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:simple_icons/simple_icons.dart';

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

  /// Helper method to get custom SVG file
  Future<File?> _getCustomSvgFile(String logoId) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final logoPath = path.join(appDocDir.path, 'custom_logos', '$logoId.svg');
      final file = File(logoPath);

      if (await file.exists()) {
        return file;
      }
    } catch (e) {
      debugPrint('Error accessing custom SVG file: $e');
    }
    return null;
  }

  /// Helper method to build initials fallback
  Widget _buildInitials() {
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
    return CircleAvatar(
      backgroundColor: background ?? Colors.grey[100],
      radius: size / 2,
      child:
          initials.isNotEmpty
              ? Text(
                initials,
                key: const Key('logo-initials'),
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              )
              : Icon(
                Icons.credit_card,
                size: size * 0.6,
                color: Colors.black54,
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Direct IconData support (highest priority)
    if (logoIcon != null) {
      return CircleAvatar(
        backgroundColor: background ?? Colors.grey[100],
        radius: size / 2,
        child: Icon(
          logoIcon,
          color: Theme.of(context).colorScheme.primary,
          size: size * 0.7,
        ),
      );
    }

    // Custom SVG support (e.g., "custom_svg:logo_id")
    if (logoKey != null && logoKey!.startsWith('custom_svg:')) {
      final logoId = logoKey!.substring('custom_svg:'.length);
      return FutureBuilder<File?>(
        future: _getCustomSvgFile(logoId),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final file = snapshot.data!;
            return CircleAvatar(
              backgroundColor: background ?? Colors.grey[100],
              radius: size / 2,
              child: ClipOval(
                child: SvgPicture.file(
                  file,
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                ),
              ),
            );
          } else if (snapshot.hasError) {
            debugPrint('Error loading custom SVG: ${snapshot.error}');
          }
          // Fall back to initials if custom SVG not found or loading
          return _buildInitials();
        },
      );
    }

    // Simple Icon identifier support (e.g., "simple_icon:github")
    if (logoKey != null && logoKey!.startsWith('simple_icon:')) {
      final iconName = logoKey!.substring('simple_icon:'.length);
      final Map<String, IconData> iconMap = {
        'amazon': SimpleIcons.amazon,
        'apple': SimpleIcons.apple,
        'google': SimpleIcons.google,
        'netflix': SimpleIcons.netflix,
        'spotify': SimpleIcons.spotify,
        'uber': SimpleIcons.uber,
        'facebook': SimpleIcons.facebook,
        'instagram': SimpleIcons.instagram,
        'youtube': SimpleIcons.youtube,
        'github': SimpleIcons.github,
        'discord': SimpleIcons.discord,
        'slack': SimpleIcons.slack,
        'zoom': SimpleIcons.zoom,
        'dropbox': SimpleIcons.dropbox,
        'paypal': SimpleIcons.paypal,
        'visa': SimpleIcons.visa,
        'mastercard': SimpleIcons.mastercard,
        'carrefour': SimpleIcons.carrefour,
        'aldinord': SimpleIcons.aldinord,
        'lidl': SimpleIcons.lidl,
      };

      final icon = iconMap[iconName];
      if (icon != null) {
        return CircleAvatar(
          backgroundColor: background ?? Colors.grey[100],
          radius: size / 2,
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: size * 0.7,
          ),
        );
      }
    }

    // SimpleIcons support (legacy)
    if (logoKey != null &&
        logoKey!.isNotEmpty &&
        SimpleIcons.values.containsKey(logoKey)) {
      final icon = SimpleIcons.values[logoKey!];
      return CircleAvatar(
        backgroundColor: background ?? Colors.grey[100],
        radius: size / 2,
        child: Icon(
          icon,
          color: Colors.black,
          size: size * 0.7,
          semanticLabel: logoKey,
        ),
      );
    }
    // SVG/file support
    if (logoKey != null && logoKey!.isNotEmpty) {
      try {
        final file = File(logoKey!);
        if (file.existsSync()) {
          if (logoKey!.toLowerCase().endsWith('.svg')) {
            return CircleAvatar(
              backgroundColor: background ?? Colors.grey[100],
              radius: size / 2,
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
            return CircleAvatar(
              backgroundColor: background ?? Colors.grey[100],
              radius: size / 2,
              backgroundImage: FileImage(file),
            );
          }
        }
      } catch (_) {
        // If any error occurs, fallback to initials
      }
    }
    // Initials fallback
    return _buildInitials();
  }
}
