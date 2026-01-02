import 'package:flutter/material.dart';

import '../helpers/database_helper.dart';
import '../helpers/i_database_helper.dart';
import '../models/card_item.dart';
import '../services/brightness_service.dart';
import '../services/share_service.dart';

/// Controller that encapsulates non-UI responsibilities for the CardDetailPage.
///
/// Responsibilities:
/// - Manage brightness lifecycle when viewing a card
/// - Coordinate delete flows with the database
/// - Delegate sharing functionality to ShareService
class CardDetailController {
  final CardItem card;
  final IDatabaseHelper _dbHelper;
  double? _originalBrightness;

  CardDetailController({required this.card, IDatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  /// Set screen brightness to maximum and store original value.
  /// Returns the original brightness so callers can keep track if needed.
  Future<double?> setBrightnessToMax() async {
    try {
      _originalBrightness = await BrightnessService.current();
      if (_originalBrightness == null) _originalBrightness = 0.5;
      await BrightnessService.set(1.0);
      return _originalBrightness;
    } catch (e) {
      debugPrint('Brightness set failed: $e');
      return _originalBrightness;
    }
  }

  /// Restore previously stored brightness.
  Future<void> restoreBrightness() async {
    try {
      if (_originalBrightness != null) {
        await BrightnessService.set(_originalBrightness!);
      }
    } catch (e) {
      debugPrint('Brightness restore failed: $e');
    }
  }

  /// Delete the card if it has an id. Throws on failure.
  Future<void> deleteCard() async {
    if (card.id == null) return;
    await _dbHelper.deleteCard(card.id!);
  }

  /// Share the card as an image via ShareService.
  Future<void> shareAsImage(BuildContext context) async {
    await ShareService.shareCardAsImageStatic(context, card);
  }
}
