import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AiScannerService {
  static const _baseUrl = 'https://generativelanguage.googleapis.com';

  static String? _cachedModel;

  static Future<String?> _findAvailableModel(String apiKey) async {
    if (_cachedModel != null) return _cachedModel;

    for (final version in ['v1', 'v1beta']) {
      final url = Uri.parse('$_baseUrl/$version/models?key=$apiKey');
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          final models = json['models'] as List<dynamic>? ?? [];

          // Prefer flash models, for faster response
          final preferredKeywords = ['flash-lite', 'flash', 'pro'];

          for (final keyword in preferredKeywords) {
            for (final model in models) {
              final name = model['name'] as String? ?? '';
              final methods =
                  (model['supportedGenerationMethods'] as List<dynamic>?)
                      ?.cast<String>() ??
                  [];

              if (name.contains(keyword) &&
                  methods.contains('generateContent')) {
                final modelId = name.startsWith('models/')
                    ? name.substring(7)
                    : name;
                debugPrint('AI Scanner: Found model "$modelId" on $version');
                _cachedModel = '$version|$modelId';
                return _cachedModel;
              }
            }
          }
        }
      } catch (e) {
        debugPrint('AI Scanner: Failed to list models on $version: $e');
      }
    }
    return null;
  }

  /// Scans prescription and returns a list of ALL medications found.
  static Future<List<Map<String, dynamic>>> scanPrescription(
    File imageFile,
  ) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY') {
      throw Exception(
        'Gemini API Key is not configured. Please set GEMINI_API_KEY in your .env file.',
      );
    }

    // Encode image (uses original bytes; compression is best-effort)
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    const prompt = '''
        Extract ALL medications from this prescription image. Reply with ONLY a JSON array.
        Format: [{"name":"...","milligrams":"...","type":"pills|capsules|liquid|eyedrops|sachet","dose":"1","time":"08:00","meal_instruction":"Before Meal|After Meal|While Eating"}]
        If milligrams is not specified, use empty string. No explanation, no markdown, just JSON.''';

    // Auto-discover available model
    final discovered = await _findAvailableModel(apiKey);
    if (discovered == null) {
      throw Exception(
        'No compatible Gemini model found for your API key. '
        'Please verify your API key is valid at https://aistudio.google.com/apikey',
      );
    }

    final parts = discovered.split('|');
    final apiVersion = parts[0];
    final modelName = parts[1];

    debugPrint('AI Scanner: Using model "$modelName" on API $apiVersion');

    try {
      return await _callGeminiApi(
        apiKey: apiKey,
        apiVersion: apiVersion,
        model: modelName,
        base64Image: base64Image,
        prompt: prompt,
      );
    } catch (e) {
      final errStr = e.toString();
      final redirectMatch = RegExp(r'use models/(\S+)').firstMatch(errStr);
      if (redirectMatch != null) {
        final suggestedModel = redirectMatch.group(1)!;
        debugPrint('AI Scanner: Redirected to model "$suggestedModel"');
        _cachedModel = '$apiVersion|$suggestedModel';

        return _callGeminiApi(
          apiKey: apiKey,
          apiVersion: apiVersion,
          model: suggestedModel,
          base64Image: base64Image,
          prompt: prompt,
        );
      }
      rethrow;
    }
  }

  // Calls Gemini API
  static Future<List<Map<String, dynamic>>> _callGeminiApi({
    required String apiKey,
    required String apiVersion,
    required String model,
    required String base64Image,
    required String prompt,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/$apiVersion/models/$model:generateContent?key=$apiKey',
    );

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image},
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.1,
        'maxOutputTokens':
            2048,
      },
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini API error (${response.statusCode}): ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = json['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No candidates in Gemini response.');
    }

    final content = candidates[0]['content'] as Map<String, dynamic>?;
    final contentParts = content?['parts'] as List<dynamic>?;
    if (contentParts == null || contentParts.isEmpty) {
      throw Exception('No parts in Gemini response.');
    }

    final text = contentParts[0]['text'] as String?;
    if (text == null || text.isEmpty) {
      throw Exception('Empty text in Gemini response.');
    }

    return _parseJsonList(text);
  }

  static List<Map<String, dynamic>> _parseJsonList(String text) {
    final trimmed = text.trim();

    // Try parsing as array first
    final arrStart = trimmed.indexOf('[');
    final arrEnd = trimmed.lastIndexOf(']');
    if (arrStart != -1 && arrEnd != -1 && arrEnd > arrStart) {
      final jsonStr = trimmed.substring(arrStart, arrEnd + 1);
      final decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    }

    // Fallback: try parsing as single object
    final objStart = trimmed.indexOf('{');
    final objEnd = trimmed.lastIndexOf('}');
    if (objStart != -1 && objEnd != -1 && objEnd > objStart) {
      final jsonStr = trimmed.substring(objStart, objEnd + 1);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      return [decoded];
    }

    throw FormatException('No JSON found in response: $text');
  }
}
