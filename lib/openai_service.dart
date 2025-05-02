import 'dart:convert';

import 'package:allen/secrets.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  Future<String> GeminiAPI(String prompt) async {
    try {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent'
        '?key=$geminiApiKey',
      );
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            }
          ]
        }),
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(res.body);
        final candidates = body['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            // Join all parts' text
            return parts.map((p) => p['text']?.toString() ?? '').join();
          }
        }
        return '⚠️ No content returned by Gemini.';
      } else {
        return '❌ Error ${res.statusCode}: ${res.body}';
      }
    } catch (e) {
      return '🚨 Exception: $e';
    }
  }
}
