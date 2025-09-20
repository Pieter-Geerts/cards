import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';

/// Preset card definitions for quick add flow
class PresetCard {
  final String title;
  final IconData logoIcon;
  const PresetCard({required this.title, required this.logoIcon});
}

const List<PresetCard> kPresetCards = [
  PresetCard(
    title: 'Albert Heijn Bonuskaart',
    logoIcon: SimpleIcons.albertheijn,
  ),
  //PresetCard(title: 'HEMA Klantenpas', logoIcon: SimpleIcons.hem),
  PresetCard(title: 'Walmart', logoIcon: SimpleIcons.walmart),
  PresetCard(title: 'Aldi', logoIcon: SimpleIcons.aldinord),
  PresetCard(title: 'Lidl', logoIcon: SimpleIcons.lidl),
  PresetCard(title: 'Carrefour', logoIcon: SimpleIcons.carrefour),
  // Add more popular cards here
];
