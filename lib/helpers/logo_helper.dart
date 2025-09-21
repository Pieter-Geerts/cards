import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../utils/simple_icons_mapping.dart';

/// Helper class for logo-related operations
/// Focuses on Simple Icons with optional file upload support
class LogoHelper {
  /// Suggests a logo based on the given title
  /// Returns the IconData if a matching logo is found, null otherwise
  static Future<IconData?> suggestLogo(String title) async {
    final normalized = title.trim().toLowerCase().replaceAll(' ', '');
    if (normalized.isEmpty) return null;

    // Use the SimpleIconsMapping to find matching logos
    final allIcons = SimpleIconsMapping.getAllIcons();

    // Create a mapping of common titles to Simple Icons
    final Map<String, IconData> logoMap = {};

    for (final icon in allIcons) {
      final identifier = SimpleIconsMapping.getIdentifier(icon);
      if (identifier != null) {
        final iconName = identifier.substring('simple_icon:'.length);
        logoMap[iconName] = icon;
      }
    }

    return logoMap[normalized];
  }

  /// Gets all available logo assets from Simple Icons
  static Future<List<IconData>> getAllAvailableLogos() async {
    try {
      return SimpleIconsMapping.getAllIcons();
    } catch (e) {
      debugPrint('Error loading available logos: $e');
      return [];
    }
  }

  /// Saves an uploaded logo file to the app's document directory
  /// Returns the file path if successful, null otherwise
  static Future<String?> saveUploadedLogo(XFile file) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final logoDir = Directory(path.join(appDocDir.path, 'logos'));

      // Create the logos directory if it doesn't exist
      if (!await logoDir.exists()) {
        await logoDir.create(recursive: true);
      }

      // Generate a unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(file.name);
      final fileName = 'logo_$timestamp$extension';
      final filePath = path.join(logoDir.path, fileName);

      // Copy the file to the app directory
      final bytes = await file.readAsBytes();
      final newFile = File(filePath);
      await newFile.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      debugPrint('Error saving uploaded logo: $e');
      return null;
    }
  }

  /// Deletes a logo file if it's a user-uploaded file
  /// (doesn't delete asset files or Simple Icons)
  static Future<bool> deleteLogo(String logoPath) async {
    try {
      // Don't delete Simple Icons (they're not files)
      if (logoPath.startsWith('simple_icon:')) {
        return false;
      }

      // Only delete files in the app's document directory
      if (logoPath.startsWith('assets/')) {
        return false; // Don't delete asset files
      }

      final file = File(logoPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting logo: $e');
      return false;
    }
  }

  /// Checks if a logo path is valid
  /// Supports Simple Icons, assets, and existing files
  static Future<bool> isValidLogoPath(String logoPath) async {
    try {
      // Check Simple Icons
      if (logoPath.startsWith('simple_icon:')) {
        final icon = SimpleIconsMapping.getIcon(logoPath);
        return icon != null;
      }

      // Check assets
      if (logoPath.startsWith('assets/')) {
        await rootBundle.load(logoPath);
        return true;
      }

      // Check file existence
      final file = File(logoPath);
      return await file.exists();
    } catch (_) {
      return false;
    }
  }
}
