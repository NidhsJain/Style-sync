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
  static Map<String, List<String>> _getHardcodedSuggestions(String lowerDesc) {
    if (lowerDesc.contains('topwear') || lowerDesc.contains('shirt') || lowerDesc.contains('top')) {
      return {
        'topwear': [],
        'bottomwear': ['Blue Jeans', 'Black Trousers', 'Casual Shorts'],
        'footwear': ['White Sneakers', 'Formal Shoes'],
        'accessories': ['Watch', 'Sunglasses'],
        'jewellery': [],
      };
    } else if (lowerDesc.contains('bottomwear') || lowerDesc.contains('pants') || lowerDesc.contains('jeans') || lowerDesc.contains('shorts') || lowerDesc.contains('trousers')) {
      return {
        'topwear': ['White T-shirt', 'Casual Shirt', 'Hoodie'],
        'bottomwear': [],
        'footwear': ['Sneakers', 'Loafers'],
        'accessories': ['Bag', 'Watch'],
        'jewellery': [],
      };
    } else if (lowerDesc.contains('dress') || lowerDesc.contains('gown')) {
      return {
        'topwear': [],
        'bottomwear': [],
        'footwear': ['Heels', 'Sandals'],
        'accessories': ['Handbag', 'Earrings'],
        'jewellery': [],
      };
    } else {
      return {
        'topwear': ['White T-shirt', 'Casual Shirt'],
        'bottomwear': ['Blue Jeans', 'Black Trousers'],
        'footwear': ['Sneakers', 'Formal Shoes'],
        'accessories': ['Watch', 'Sunglasses'],
        'jewellery': [],
      };
    }
  }

  static Future<Map<String, List<String>>> getSuggestions({
    required String clothingDescription,
    required String gender,
  }) async {
    String lowerDesc = clothingDescription.toLowerCase();
    Map<String, List<String>> hardcoded = _getHardcodedSuggestions(lowerDesc);

    String categoryRules = "";
    if (lowerDesc.contains('topwear') || lowerDesc.contains('shirt') || lowerDesc.contains('top')) {
      categoryRules = '''
- Leave "topwear" empty.
- Provide exactly 2 items for "bottomwear" (jeans, trousers, skirts, etc.).
- Provide exactly 2 items for "footwear" (sneakers, shoes, heels, etc.).
- Provide exactly 2 items for "accessories" (bags, sunglasses, etc.).
- Provide exactly 2 items for "jewellery".
''';
    } else if (lowerDesc.contains('bottomwear') || lowerDesc.contains('pants') || lowerDesc.contains('jeans') || lowerDesc.contains('shorts') || lowerDesc.contains('trousers')) {
      categoryRules = '''
- Provide exactly 2 items for "topwear" (t-shirts, shirts, tops, etc.).
- Leave "bottomwear" empty.
- Provide exactly 2 items for "footwear".
- Provide exactly 2 items for "accessories".
- Provide exactly 2 items for "jewellery".
''';
    } else if (lowerDesc.contains('dress') || lowerDesc.contains('gown')) {
      categoryRules = '''
- Leave "topwear" and "bottomwear" empty.
- Provide exactly 2 items for "footwear".
- Provide exactly 2 items for "accessories".
- Provide exactly 2 items for "jewellery".
''';
    } else {
      categoryRules = '''
- Provide exactly 2 items for "topwear".
- Provide exactly 2 items for "bottomwear".
- Provide exactly 2 items for "footwear".
- Provide exactly 2 items for "accessories".
- Provide exactly 2 items for "jewellery".
''';
    }

    final prompt = '''
You are a professional fashion stylist.

A $gender customer is wearing a "$clothingDescription".

Suggest matching items to complete the outfit.
$categoryRules

Do NOT suggest the scanned clothing item again.
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
        return hardcoded; // Return hardcoded on error instead of throwing
      }

      debugPrint('  [Groq] ✓ Status 200 — parsing response...');
      final decoded = jsonDecode(response.body);
      final content = decoded['choices'][0]['message']['content'] as String;
      
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;
      if (jsonStart == -1 || jsonEnd <= jsonStart) {
        return hardcoded; // Return hardcoded on parse error
      }
      
      final jsonStr = content.substring(jsonStart, jsonEnd);
      final outfitJson = jsonDecode(jsonStr) as Map<String, dynamic>;

      final result = {
        'topwear': [...hardcoded['topwear']!, ..._toStringList(outfitJson['topwear'])].toSet().toList(),
        'bottomwear': [...hardcoded['bottomwear']!, ..._toStringList(outfitJson['bottomwear'])].toSet().toList(),
        'footwear': [...hardcoded['footwear']!, ..._toStringList(outfitJson['footwear'])].toSet().toList(),
        'accessories': [...hardcoded['accessories']!, ..._toStringList(outfitJson['accessories'])].toSet().toList(),
        'jewellery': [...hardcoded['jewellery']!, ..._toStringList(outfitJson['jewellery'])].toSet().toList(),
      };

      SuggestionHistoryService().saveHistory(SuggestionHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        clothingDescription: clothingDescription,
        suggestions: result,
        dateTime: DateTime.now(),
      ));

      return result;
    } catch (e) {
      debugPrint('  [Groq] Exception caught, returning hardcoded suggestions: $e');
      return hardcoded;
    }
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}
