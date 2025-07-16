import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';

/// Widget to display either a brand logo (SimpleIcons), SVG/file, or initials fallback.
class LogoAvatarWidget extends StatelessWidget {
  final String? logoKey;
  final String? title;
  final double size;
  final Color? background;

  const LogoAvatarWidget({
    super.key,
    this.logoKey,
    this.title,
    this.size = 48,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    // SimpleIcons support
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
}
