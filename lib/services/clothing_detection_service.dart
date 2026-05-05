import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ClothingDetectionService {
  static Future<Map<String, String>> analyzeClothing(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) {
      return {'color': 'Grey', 'type': 'Bottomwear', 'description': 'Grey Bottomwear'};
    }

    // 1. Always crop center 40% of the image before processing (Avoids gallery background noise)
    int cropWidth = (original.width * 0.4).toInt();
    int cropHeight = (original.height * 0.4).toInt();
    int cropX = (original.width - cropWidth) ~/ 2;
    int cropY = (original.height - cropHeight) ~/ 2;
    
    final cropped = img.copyCrop(original, x: cropX, y: cropY, width: cropWidth, height: cropHeight);

    // 2. Resize cropped image to 50x50 before analysis (for speed)
    final processingImage = img.copyResize(cropped, width: 50, height: 50);

    // 3. Majority Pixel Voting for Color Detection
    Map<String, int> colorCounts = {};
    for (int y = 0; y < processingImage.height; y++) {
      for (int x = 0; x < processingImage.width; x++) {
        final p = processingImage.getPixel(x, y);
        final hsv = _rgbToHsv(p.r.toInt(), p.g.toInt(), p.b.toInt());
        final colorName = _hsvToColorName(hsv[0], hsv[1], hsv[2]);
        colorCounts[colorName] = (colorCounts[colorName] ?? 0) + 1;
      }
    }

    String dominantColor = 'Grey';
    int maxCount = -1;
    colorCounts.forEach((color, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantColor = color;
      }
    });

    // 4. Compute aspect ratio correctly: double ratio = height / width;
    double ratio = original.height / original.width;
    String clothingType = 'Bottomwear'; // Default fallback

    if (ratio > 1.3) {
      clothingType = 'Dress';
    } else if (ratio < 0.8) {
      clothingType = 'Topwear';
    } else {
      clothingType = 'Bottomwear';
    }

    // 5. Add keyword override
    final textToCheck = imagePath.toLowerCase();
    if (textToCheck.contains('jeans') || textToCheck.contains('pants') || 
        textToCheck.contains('trousers') || textToCheck.contains('shorts')) {
      clothingType = 'Bottomwear';
    } else if (textToCheck.contains('dress') || textToCheck.contains('gown')) {
      clothingType = 'Dress';
    } else if (textToCheck.contains('shirt') || textToCheck.contains('t-shirt') || textToCheck.contains('top')) {
      clothingType = 'Topwear';
    }

    final description = '$dominantColor $clothingType';

    debugPrint('  [ClothingDetection] Dominant Color: $dominantColor');
    debugPrint('  [ClothingDetection] Clothing Type: $clothingType (Ratio: $ratio)');
    debugPrint('  [ClothingDetection] Final Description: $description');

    return {
      'color': dominantColor,
      'type': clothingType,
      'description': description,
    };
  }

  // Convert RGB pixels to HSV color space
  static List<double> _rgbToHsv(int r, int g, int b) {
    final rNorm = r / 255.0;
    final gNorm = g / 255.0;
    final bNorm = b / 255.0;

    final mx = max(rNorm, max(gNorm, bNorm));
    final mn = min(rNorm, min(gNorm, bNorm));
    final d = mx - mn;

    double h = 0;
    if (d > 0.0001) {
      if (mx == rNorm) {
        h = 60.0 * (((gNorm - bNorm) / d) % 6.0);
      } else if (mx == gNorm) {
        h = 60.0 * (((bNorm - rNorm) / d) + 2.0);
      } else {
        h = 60.0 * (((rNorm - gNorm) / d) + 4.0);
      }
      if (h < 0) h += 360.0;
    }

    final s = mx < 0.0001 ? 0.0 : d / mx;
    return [h, s, mx]; // Hue [0..360], Saturation [0..1], Value [0..1]
  }

  // Apply explicit improved thresholds
  static String _hsvToColorName(double h, double s, double v) {
    if (v < 0.2) return 'Black';
    if (v > 0.85 && s < 0.2) return 'White';
    if (s < 0.25) return 'Grey';
    
    if (h < 15 || h > 345) return 'Red';
    if (h >= 15 && h <= 35) return 'Orange';
    if (h > 35 && h <= 65) return 'Yellow';
    if (h > 65 && h <= 170) return 'Green';
    if (h > 170 && h <= 260) return 'Blue';
    if (h > 260 && h <= 290) return 'Purple';
    if (h > 290 && h <= 345) return 'Pink';

    return 'Grey';
  }
}

