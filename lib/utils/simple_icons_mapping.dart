import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';

/// Unified Simple Icons mapping utility
/// Provides consistent icon-to-identifier conversion across the app
class SimpleIconsMapping {
  /// Public getter for icon-to-identifier map
  static Map<IconData, String> get iconToIdentifier => _iconToIdentifier;

  /// Complete mapping of supported Simple Icons to their identifiers
  static final Map<IconData, String> _iconToIdentifier = {
    // Supermarkets & Grocery
    SimpleIcons.carrefour: 'simple_icon:carrefour',
    SimpleIcons.aldinord: 'simple_icon:aldinord',
    SimpleIcons.lidl: 'simple_icon:lidl',
    SimpleIcons.walmart: 'simple_icon:walmart',
    SimpleIcons.target: 'simple_icon:target',
    SimpleIcons.tesco: 'simple_icon:tesco',
    SimpleIcons.albertheijn: 'simple_icon:albertheijn',

    // Department Stores & Furniture
    SimpleIcons.ikea: 'simple_icon:ikea',

    // Fashion & Clothing
    SimpleIcons.nike: 'simple_icon:nike',
    SimpleIcons.adidas: 'simple_icon:adidas',
    SimpleIcons.puma: 'simple_icon:puma',
    SimpleIcons.zara: 'simple_icon:zara',

    // Online Retail
    SimpleIcons.amazon: 'simple_icon:amazon',
    SimpleIcons.ebay: 'simple_icon:ebay',
    SimpleIcons.etsy: 'simple_icon:etsy',
    SimpleIcons.shopify: 'simple_icon:shopify',

    // Food & Restaurants
    SimpleIcons.mcdonalds: 'simple_icon:mcdonalds',
    SimpleIcons.burgerking: 'simple_icon:burgerking',
    SimpleIcons.kfc: 'simple_icon:kfc',
    SimpleIcons.starbucks: 'simple_icon:starbucks',
    SimpleIcons.tacobell: 'simple_icon:tacobell',

    // Technology & Services
    SimpleIcons.apple: 'simple_icon:apple',
    SimpleIcons.google: 'simple_icon:google',
    SimpleIcons.netflix: 'simple_icon:netflix',
    SimpleIcons.spotify: 'simple_icon:spotify',
    SimpleIcons.uber: 'simple_icon:uber',
    SimpleIcons.facebook: 'simple_icon:facebook',
    SimpleIcons.instagram: 'simple_icon:instagram',
    SimpleIcons.youtube: 'simple_icon:youtube',
    SimpleIcons.github: 'simple_icon:github',
    SimpleIcons.discord: 'simple_icon:discord',
    SimpleIcons.slack: 'simple_icon:slack',
    SimpleIcons.zoom: 'simple_icon:zoom',
    SimpleIcons.dropbox: 'simple_icon:dropbox',

    // Financial
    SimpleIcons.paypal: 'simple_icon:paypal',
    SimpleIcons.visa: 'simple_icon:visa',
    SimpleIcons.mastercard: 'simple_icon:mastercard',
  };

  /// Reverse mapping for identifier-to-icon conversion
  static final Map<String, IconData> _identifierToIcon = {
    for (var entry in _iconToIdentifier.entries) entry.value: entry.key,
  };

  /// Get Simple Icon identifier from IconData
  static String? getIdentifier(IconData icon) {
    return _iconToIdentifier[icon];
  }

  /// Get IconData from Simple Icon identifier
  static IconData? getIcon(String identifier) {
    if (!identifier.startsWith('simple_icon:')) return null;
    return _identifierToIcon[identifier];
  }

  /// Get all available icons
  static List<IconData> getAllIcons() {
    return _iconToIdentifier.keys.toList();
  }

  /// Check if an icon is supported
  static bool isSupported(IconData icon) {
    return _iconToIdentifier.containsKey(icon);
  }

  /// Check if an identifier is valid
  static bool isValidIdentifier(String identifier) {
    return identifier.startsWith('simple_icon:') &&
        _identifierToIcon.containsKey(identifier);
  }
}
