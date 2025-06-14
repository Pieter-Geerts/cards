import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class LogoDevService {
  static const String _baseUrl = 'https://api.logo.dev/v1';
  final String apiKey;

  LogoDevService(this.apiKey);

  // Fetch a single high-quality logo by company name or domain (for direct logo display)
  Future<String?> fetchLogoUrl(String companyNameOrDomain) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/logo?company=$companyNameOrDomain'),
      headers: {
        'Authorization': 'Bearer: $apiKey',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['logo_url'] as String?;
    }
    return null;
  }

  // Download the best logo for a company and save it to local storage, returning the file path
  Future<String?> downloadAndSaveLogo(String companyNameOrDomain) async {
    // Always construct the image URL with the correct API key
    final imageUrl = 'https://img.logo.dev/$companyNameOrDomain?token=$apiKey';
    print(
      '[LogoDevService] Downloading logo for "$companyNameOrDomain" from: $imageUrl',
    );
    try {
      final response = await http.get(Uri.parse(imageUrl));
      print(
        '[LogoDevService] HTTP status: \\${response.statusCode}, content-type: \\${response.headers['content-type']}',
      );
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        if (!contentType.startsWith('image/')) {
          return null;
        }
        final bytes = response.bodyBytes;
        final dir = await getApplicationDocumentsDirectory();
        final ext = imageUrl.endsWith('.svg') ? 'svg' : 'png';
        final filePath =
            '${dir.path}/logo_${companyNameOrDomain}_${DateTime.now().millisecondsSinceEpoch}.$ext';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        return filePath;
      } 

    } catch (e) {
      print('[LogoDevService] Logo download error: $e');
    }
    return null;
  }

  // Search for companies and their logos (for search UI)
  Future<List<Map<String, dynamic>>> searchCompanies(String query) async {
    final response = await http.get(
      Uri.parse('https://api.logo.dev/search?q=$query'),
      headers: {
        'Authorization': 'Bearer: $apiKey',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
    }
    return [];
  }
}
