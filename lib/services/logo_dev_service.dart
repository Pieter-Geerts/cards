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
      Uri.parse('$_baseUrl/logo/$companyNameOrDomain'),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'] as String?;
    } else {
      return null;
    }
  }

  Future<String?> downloadAndSaveLogo(String companyNameOrDomain) async {
    try {
      final logoUrlResponse = await http.get(
        Uri.parse(
          '$_baseUrl/logo/$companyNameOrDomain?format=png&size=200',
        ), // Request PNG, 200px
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (logoUrlResponse.statusCode == 200) {
        // Validate content type to ensure it's an image
        final contentType = logoUrlResponse.headers['content-type'] ?? '';
        if (!contentType.startsWith('image/')) {
          return null;
        }

        final logoData = logoUrlResponse.bodyBytes;
        final directory = await getApplicationDocumentsDirectory();
        final sanitizedCompanyName = companyNameOrDomain.replaceAll(
          RegExp(r'[^a-zA-Z0-9]'),
          '_',
        );
        final filePath = '${directory.path}/logo_$sanitizedCompanyName.png';
        final file = File(filePath);
        await file.writeAsBytes(logoData);
        return filePath;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Search for companies and their logos (for search UI)
  Future<List<Map<String, dynamic>>> searchCompanies(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search?query=${Uri.encodeComponent(query)}'),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }
}
