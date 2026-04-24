import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;

import '../models/card_item.dart';

class ImageScanHelper {
  // Test hook: when set, `pickAndScanImage` and `takePhotoAndScan`
  // will return this result immediately and then clear the hook.
  // Use from integration tests to avoid invoking platform image picker.
  static Map<String, dynamic>? testScanResult;

  /// Picks an image and returns it for manual scanning
  /// In the future, this can be enhanced with ML Kit for automatic detection
  static Future<Map<String, dynamic>?> pickAndScanImage() async {
    // Testing shortcut
    if (testScanResult != null) {
      final result = testScanResult;
      testScanResult = null;
      return result;
    }
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
      developer.log(
        'Error picking image: $e',
        name: 'ImageScanHelper',
        error: e,
      );
      return null;
    }
  }

  /// Takes a photo and returns it for manual scanning
  static Future<Map<String, dynamic>?> takePhotoAndScan() async {
    // Testing shortcut
    if (testScanResult != null) {
      final result = testScanResult;
      testScanResult = null;
      return result;
    }
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
      developer.log(
        'Error taking photo: $e',
        name: 'ImageScanHelper',
        error: e,
      );
      return null;
    }
  }
}
