import 'package:cards/utils/simple_icons_mapping.dart';
import 'package:flutter/material.dart';

String? getSimpleIconIdentifier(IconData icon) {
  return SimpleIconsMapping.getIdentifier(icon);
}

/// Returns a SimpleIcons identifier for supported brands, or null for initials fallback
String? getLogoPathForTitle(String title) {
  final normalized = title.trim().toLowerCase().replaceAll(' ', '');
  for (final entry in SimpleIconsMapping.iconToIdentifier.entries) {
    final key = entry.value.replaceAll('simple_icon:', '').toLowerCase();
    if (normalized.contains(key)) {
      return entry.value;
    }
  }
  return null;
}
