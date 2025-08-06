import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:simple_icons/simple_icons.dart';

/// Helper class for logo-related operations
class LogoHelper {
  /// Suggests a logo based on the given title
  /// Returns the IconData if a matching logo is found, null otherwise
  static Future<IconData?> suggestLogo(String title) async {
    final normalized = title.trim().toLowerCase().replaceAll(' ', '');
    if (normalized.isEmpty) return null;

    // Create a mapping of common titles to Simple Icons
    final Map<String, IconData> logoMap = {
      'carrefour': SimpleIcons.carrefour,
      'aldi': SimpleIcons.aldinord,
      'aldinord': SimpleIcons.aldinord,
      'lidl': SimpleIcons.lidl,
    };

    return logoMap[normalized];
  }

  /// Gets all available logo assets from Simple Icons
  static Future<List<IconData>> getAllAvailableLogos() async {
    try {
      // Return a curated list of retail/shop brand icons from Simple Icons
      // Conservative list with icons that definitely exist
      return [
        // Supermarkets & Grocery
        SimpleIcons.carrefour,
        SimpleIcons.aldinord,
        SimpleIcons.lidl,
        SimpleIcons.walmart,
        SimpleIcons.target,
        SimpleIcons.tesco,

        // Department Stores & Furniture
        SimpleIcons.ikea,

        // Fashion & Clothing
        SimpleIcons.nike,
        SimpleIcons.adidas,
        SimpleIcons.puma,
        SimpleIcons.zara,

        // Online Retail
        SimpleIcons.amazon,
        SimpleIcons.ebay,
        SimpleIcons.etsy,
        SimpleIcons.shopify,

        // Food & Restaurants
        SimpleIcons.mcdonalds,
        SimpleIcons.burgerking,
        SimpleIcons.kfc,
        SimpleIcons.starbucks,
        SimpleIcons.tacobell,
      ];
    } catch (e) {
      debugPrint('Error loading available logos: $e');
      return [];
    }
  }

  /// Gets custom SVG logos from backend
  static Future<List<Map<String, String>>> getCustomLogosFromBackend() async {
    try {
      // TODO: Replace with your actual backend API endpoint
      // Example implementation:
      // final response = await http.get(Uri.parse('https://your-api.com/logos'));
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
      //   return data.map((item) => {
      //     'id': item['id'].toString(),
      //     'name': item['name'].toString(),
      //     'svgUrl': item['svgUrl'].toString(),
      //   }).toList();
      // }

      // Mock data for now - replace with actual API call
      return [
        {
          'id': 'custom_1',
          'name': 'Local Store',
          'svgUrl': 'https://example.com/store1.svg',
        },
        {
          'id': 'custom_2',
          'name': 'My Shop',
          'svgUrl': 'https://example.com/shop2.svg',
        },
      ];
    } catch (e) {
      debugPrint('Error loading custom logos from backend: $e');
      return [];
    }
  }

  /// Downloads and saves an SVG from a URL to local storage
  static Future<String?> downloadAndSaveSvg(
    String svgUrl,
    String logoId,
  ) async {
    try {
      // TODO: Add http dependency to pubspec.yaml and implement
      // final response = await http.get(Uri.parse(svgUrl));
      // if (response.statusCode == 200) {
      //   final appDocDir = await getApplicationDocumentsDirectory();
      //   final logoDir = Directory(path.join(appDocDir.path, 'custom_logos'));
      //
      //   if (!await logoDir.exists()) {
      //     await logoDir.create(recursive: true);
      //   }
      //
      //   final fileName = '$logoId.svg';
      //   final filePath = path.join(logoDir.path, fileName);
      //   final file = File(filePath);
      //   await file.writeAsBytes(response.bodyBytes);
      //
      //   return 'custom_svg:$logoId';
      // }

      debugPrint('SVG download not implemented yet - add http dependency');
      return null;
    } catch (e) {
      debugPrint('Error downloading SVG: $e');
      return null;
    }
  }

  /// Gets all locally stored custom SVG logos
  static Future<List<String>> getLocalCustomLogos() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final logoDir = Directory(path.join(appDocDir.path, 'custom_logos'));

      if (!await logoDir.exists()) {
        return [];
      }

      final files =
          logoDir.listSync().where((file) => file.path.endsWith('.svg')).map((
            file,
          ) {
            final fileName = path.basenameWithoutExtension(file.path);
            return 'custom_svg:$fileName';
          }).toList();

      return files;
    } catch (e) {
      debugPrint('Error loading local custom logos: $e');
      return [];
    }
  }

  /// Saves an SVG string directly to local storage
  static Future<String?> saveCustomSvg(
    String svgContent,
    String logoName,
  ) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final logoDir = Directory(path.join(appDocDir.path, 'custom_logos'));

      if (!await logoDir.exists()) {
        await logoDir.create(recursive: true);
      }

      // Create a safe filename
      final safeLogoName = logoName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${safeLogoName}_$timestamp.svg';
      final filePath = path.join(logoDir.path, fileName);

      final file = File(filePath);
      await file.writeAsString(svgContent);

      final logoId = path.basenameWithoutExtension(fileName);
      return 'custom_svg:$logoId';
    } catch (e) {
      debugPrint('Error saving custom SVG: $e');
      return null;
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
  /// (doesn't delete asset files)
  static Future<bool> deleteLogo(String logoPath) async {
    try {
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

  /// Checks if a logo path is valid (either an asset or an existing file)
  static Future<bool> isValidLogoPath(String logoPath) async {
    try {
      if (logoPath.startsWith('assets/')) {
        // Check if asset exists
        await rootBundle.load(logoPath);
        return true;
      } else {
        // Check if file exists
        final file = File(logoPath);
        return await file.exists();
      }
    } catch (_) {
      return false;
    }
  }
}
