import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

/// Generates a full-body AI avatar using HuggingFace Stable Diffusion XL.
///
/// ⚠️ API TOKEN: Set your token in lib/config/api_keys.dart → ApiKeys.huggingFaceToken
class AvatarGenerationService {
  static const String _hfToken = ApiKeys.huggingFaceToken;


  static const String _apiUrl =
      'https://router.huggingface.co/hf-inference/models/stabilityai/stable-diffusion-xl-base-1.0';

  /// Generates a full-body avatar image.
  ///
  /// [gender] is 'Male' or 'Female'.
  /// [outfit] is the suggestions map from OutfitAIService.
  /// [detectedClothing] is the scanned item description.
  ///
  /// Returns raw image bytes (PNG/JPEG) on success, or null on failure.
  static Future<dynamic> generateAvatar({
    required String gender,
    required Map<String, List<String>> outfit,
    required String detectedClothing,
  }) async {
    const String fallbackUrl = 'https://api.dicebear.com/7.x/avataaars/png?seed=user';

    if (_hfToken.isEmpty || _hfToken == 'YOUR_HUGGING_FACE_TOKEN_HERE' || _hfToken.contains('YOUR_')) {
      debugPrint('  [Avatar] API Token is missing or placeholder. Returning fallback URL.');
      return fallbackUrl;
    }

    final prompt = _buildPrompt(gender: gender, outfit: outfit, detectedClothing: detectedClothing);
    debugPrint('  [Avatar] Prompt: $prompt');

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_hfToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': prompt,
          'parameters': {
            'num_inference_steps': 30,
            'guidance_scale': 7.5,
            'width': 512,
            'height': 768,
          },
        }),
      ).timeout(const Duration(seconds: 120));

      debugPrint('  [Avatar] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('  [Avatar] ✓ Success — ${response.bodyBytes.length} bytes');
        return response.bodyBytes;
      } else if (response.statusCode == 503) {
        debugPrint('  [Avatar] Model loading (503) — retrying after 20s...');
        await Future.delayed(const Duration(seconds: 20));
        final retry = await http.post(
          Uri.parse(_apiUrl),
          headers: {
            'Authorization': 'Bearer $_hfToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'inputs': prompt,
            'parameters': {
              'num_inference_steps': 30,
              'guidance_scale': 7.5,
              'width': 512,
              'height': 768,
            },
          }),
        ).timeout(const Duration(seconds: 120));
        debugPrint('  [Avatar] Retry status: ${retry.statusCode}');
        if (retry.statusCode == 200) {
          debugPrint('  [Avatar] ✓ Retry success — ${retry.bodyBytes.length} bytes');
          return retry.bodyBytes;
        }
      } else {
        debugPrint('  [Avatar] ✗ Error ${response.statusCode}: ${response.body}');
      }
      return fallbackUrl;
    } catch (e) {
      debugPrint('  [Avatar] ✗ Exception: $e');
      return fallbackUrl;
    }
  }

  static String _buildPrompt({
    required String gender,
    required Map<String, List<String>> outfit,
    required String detectedClothing,
  }) {
    final genderWord = gender.toLowerCase();

    // Build outfit sentence from detected item + key visible accessories
    final footwearList   = outfit['footwear']    ?? [];
    final accessoryList  = outfit['accessories'] ?? [];
    final jewelleryList  = outfit['jewellery']   ?? [];

    final outfitParts = <String>[];
    outfitParts.add(detectedClothing.toLowerCase());

    if (footwearList.isNotEmpty) {
      outfitParts.add(footwearList.first.toLowerCase());
    }
    if (accessoryList.isNotEmpty) {
      outfitParts.add(accessoryList.first.toLowerCase());
    }
    if (jewelleryList.isNotEmpty) {
      outfitParts.add(jewelleryList.first.toLowerCase());
    }

    final outfitStr = outfitParts.join(', ');

    final prompt = 'Full body $genderWord fashion model wearing $outfitStr, '
        'studio fashion photography, neutral white background, '
        'full body visible from head to toe including shoes, '
        'professional lighting, high quality, 4k, editorial style';

    debugPrint('  [Avatar] Prompt: $prompt');
    return prompt;
  }
}
