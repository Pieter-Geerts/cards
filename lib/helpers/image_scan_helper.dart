import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/card_item.dart';

class ImageScanHelper {
  /// Picks an image and returns it for manual scanning
  /// In the future, this can be enhanced with ML Kit for automatic detection
  static Future<Map<String, dynamic>?> pickAndScanImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return {
          'code': '',
          'type': CardType.qrCode,
          'imagePath': image.path,
          'hasAutoDetection': false,
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Takes a photo and returns it for manual scanning
  static Future<Map<String, dynamic>?> takePhotoAndScan() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        return {
          'code': '',
          'type': CardType.qrCode,
          'imagePath': photo.path,
          'hasAutoDetection': false,
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }
}
