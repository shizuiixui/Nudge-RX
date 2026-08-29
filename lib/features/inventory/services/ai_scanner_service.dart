import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AiScannerService {
  static const _baseUrl = 'https://generativelanguage.googleapis.com';

  static int _currentKeyIndex = 0;
  static final Map<String, String> _cachedModels = {};

  // Retrieves all configured Gemini API keys from env
  static List<String> getApiKeys() {
    final Set<String> keys = {};

    // Check primary key
    final primary = dotenv.env['GEMINI_API_KEY']?.trim();
    if (primary != null && primary.isNotEmpty && primary != 'YOUR_GEMINI_API_KEY') {
      keys.add(primary);
    }

    // Check numbered keys
    for (int i = 2; i <= 10; i++) {
      final k = dotenv.env['GEMINI_API_KEY_$i']?.trim();
      if (k != null && k.isNotEmpty && k != 'YOUR_GEMINI_API_KEY') {
        keys.add(k);
      }
    }

    // Check comma-separated keys
    final csvKeys = dotenv.env['GEMINI_API_KEYS'];
    if (csvKeys != null && csvKeys.isNotEmpty) {
      for (final rawKey in csvKeys.split(',')) {
        final k = rawKey.trim();
        if (k.isNotEmpty && k != 'YOUR_GEMINI_API_KEY') {
          keys.add(k);
        }
      }
    }

    return keys.toList();
  }

  static Future<String?> _findAvailableModel(String apiKey) async {
    if (_cachedModels.containsKey(apiKey)) return _cachedModels[apiKey];

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
                debugPrint('AI Scanner: Found model "$modelId" on $version for key');
                _cachedModels[apiKey] = '$version|$modelId';
                return _cachedModels[apiKey];
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

  /// Scans prescription using round-robin rotational API keys with automatic failover.
  static Future<List<Map<String, dynamic>>> scanPrescription(
    File imageFile,
  ) async {
    final keys = getApiKeys();
    if (keys.isEmpty) {
      throw Exception(
        'No Gemini API Key found. Please set GEMINI_API_KEY, GEMINI_API_KEY_2, etc. in your .env file.',
      );
    }

    // Encode image once
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    const prompt = '''
        Extract ALL medications from this prescription image. Reply with ONLY a JSON array.
        Format: [{"name":"...","milligrams":"...","type":"pills|capsules|liquid|eyedrops|sachet","dose":"1","time":"08:00","meal_instruction":"Before Meal|After Meal|While Eating"}]
        If milligrams is not specified, use empty string. No explanation, no markdown, just JSON.''';

    // Round-robin start index
    final startIndex = _currentKeyIndex % keys.length;
    _currentKeyIndex++;

    // Attempt to scan with each key in rotational order
    List<String> errors = [];
    for (int attempt = 0; attempt < keys.length; attempt++) {
      final keyIndex = (startIndex + attempt) % keys.length;
      final currentKey = keys[keyIndex];
      final keyLabel = 'Key #${keyIndex + 1}';

      try {
        debugPrint('AI Scanner: Attempting scan with $keyLabel (Attempt ${attempt + 1}/${keys.length})...');

        // Auto-discover available model for this key
        final discovered = await _findAvailableModel(currentKey);
        if (discovered == null) {
          throw Exception('No compatible model found for $keyLabel.');
        }

        final parts = discovered.split('|');
        final apiVersion = parts[0];
        final modelName = parts[1];

        return await _callGeminiApiWithRedirect(
          apiKey: currentKey,
          apiVersion: apiVersion,
          model: modelName,
          base64Image: base64Image,
          prompt: prompt,
        );
      } catch (e) {
        final errMessage = e.toString();
        debugPrint('AI Scanner: $keyLabel failed: $errMessage');
        errors.add('$keyLabel: $errMessage');

        // If not the last key, continue to failover
        if (attempt < keys.length - 1) {
          debugPrint('AI Scanner: Failing over to next rotational key...');
        }
      }
    }

    // If all keys failed
    throw Exception(
      'All configured Gemini API keys failed or exhausted quotas.\nErrors:\n${errors.join('\n')}',
    );
  }

  static Future<List<Map<String, dynamic>>> _callGeminiApiWithRedirect({
    required String apiKey,
    required String apiVersion,
    required String model,
    required String base64Image,
    required String prompt,
  }) async {
    try {
      return await _callGeminiApi(
        apiKey: apiKey,
        apiVersion: apiVersion,
        model: model,
        base64Image: base64Image,
        prompt: prompt,
      );
    } catch (e) {
      final errStr = e.toString();
      final redirectMatch = RegExp(r'use models/(\S+)').firstMatch(errStr);
      if (redirectMatch != null) {
        final suggestedModel = redirectMatch.group(1)!;
        debugPrint('AI Scanner: Redirected to model "$suggestedModel"');
        _cachedModels[apiKey] = '$apiVersion|$suggestedModel';

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
