import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';
import '../models/suggestion_history_model.dart';
import 'suggestion_history_service.dart';

/// Calls Groq API (Llama 3) to generate structured outfit suggestions.
///
/// ⚠️ API KEY: Set your key in lib/config/api_keys.dart → ApiKeys.groqApiKey
class OutfitAIService {
  static const String _groqApiKey = ApiKeys.groqApiKey;


  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  /// Generates outfit suggestions for the given [clothingDescription] and [gender].
  ///
  /// Returns a Map with keys: topwear, bottomwear, footwear, accessories, jewellery.
  static Future<Map<String, List<String>>> getSuggestions({
    required String clothingDescription,
    required String gender,
  }) async {
    final prompt = '''
You are a professional fashion stylist.

A $gender customer is wearing a "$clothingDescription".

Suggest matching items to complete the outfit.
Do NOT suggest the scanned clothing item again.
Always provide exactly 2 specific items per category.
Use short, descriptive names suitable for image search (e.g. "black heels", "gold necklace").
Choose realistic, stylish, gender-appropriate items.

Return ONLY valid JSON in this exact format, no explanation:
{
  "topwear": [],
  "bottomwear": [],
  "footwear": [],
  "accessories": [],
  "jewellery": []
}
''';

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $_groqApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('  [Groq] ✗ Error ${response.statusCode}: ${response.body}');
        throw Exception('Groq API error ${response.statusCode}: ${response.body}');
      }

      debugPrint('  [Groq] ✓ Status 200 — parsing response...');
      final decoded = jsonDecode(response.body);
      final content = decoded['choices'][0]['message']['content'] as String;
      debugPrint('  [Groq] Raw content:\n$content');

      // Extract JSON from response (strip any surrounding text)
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;
      if (jsonStart == -1 || jsonEnd <= jsonStart) {
        throw Exception('No JSON found in Groq response');
      }
      final jsonStr = content.substring(jsonStart, jsonEnd);
      final outfitJson = jsonDecode(jsonStr) as Map<String, dynamic>;

      final result = {
        'topwear': _toStringList(outfitJson['topwear']),
        'bottomwear': _toStringList(outfitJson['bottomwear']),
        'footwear': _toStringList(outfitJson['footwear']),
        'accessories': _toStringList(outfitJson['accessories']),
        'jewellery': _toStringList(outfitJson['jewellery']),
      };

      SuggestionHistoryService().saveHistory(SuggestionHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        clothingDescription: clothingDescription,
        suggestions: result,
        dateTime: DateTime.now(),
      ));

      return result;
    } catch (e) {
      rethrow;
    }
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}
