import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ClothingDetectionService {
  static Future<Map<String, String>> analyzeClothing(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) {
      return {'color': 'Grey', 'type': 'Topwear', 'description': 'Grey Topwear'};
    }

    // 1. Resize captured image to smaller resolution (100x100)
    final resized = img.copyResize(original, width: 100, height: 100);

    // 2. Crop the center region (e.g. 50x50 from center) to reduce background influence
    final cropped = img.copyCrop(resized, x: 25, y: 25, width: 50, height: 50);

    // 4. Perform K-Means clustering (k = 3)
    final dominantColorHsv = _getDominantColorKMeans(cropped, 3);
    
    // 6. Convert dominant HSV color to a color name
    final colorName = _hsvToColorName(dominantColorHsv[0], dominantColorHsv[1], dominantColorHsv[2]);

    // 7. Determine clothing type using simple heuristics
    final double heightWidthRatio = original.height / original.width;
    final double widthHeightRatio = original.width / original.height;
    
    String clothingType;
    if (heightWidthRatio > 1.3) {
      clothingType = 'Dress';
    } else if (widthHeightRatio > 1.3) {
      clothingType = 'Shirt';
    } else {
      clothingType = 'Topwear';
    }

    // 8. Generate clothing description
    final description = '$colorName $clothingType';

    // 10. Add debug logs
    debugPrint('  [ClothingDetection] Dominant Color: $colorName');
    debugPrint('  [ClothingDetection] Clothing Type: $clothingType');
    debugPrint('  [ClothingDetection] Final Description: $description');

    return {
      'color': colorName,
      'type': clothingType,
      'description': description,
    };
  }

  // 3. Convert RGB pixels to HSV color space
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

  static List<double> _getDominantColorKMeans(img.Image image, int k) {
    List<List<double>> pixels = [];
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        // Step 3 applied per pixel
        final hsv = _rgbToHsv(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
        
        // Minor filtering for absolute white or absolute black background outliers
        if (hsv[2] > 0.95 && hsv[1] < 0.05) continue;
        if (hsv[2] < 0.05) continue;
        
        pixels.add(hsv);
      }
    }
    
    if (pixels.isEmpty) return [0, 0, 0]; // Default to black

    List<List<double>> centroids = [];
    final rand = Random();
    for (int i = 0; i < k; i++) {
      centroids.add(pixels[rand.nextInt(pixels.length)]);
    }

    List<int> assignments = List.filled(pixels.length, 0);
    bool changed = true;
    int maxIters = 10; // Cap passes for speed
    
    while (changed && maxIters-- > 0) {
      changed = false;
      List<List<double>> newCentroids = List.generate(k, (_) => [0.0, 0.0, 0.0]);
      List<int> counts = List.filled(k, 0);

      // Assign pixels to closest centroid
      for (int i = 0; i < pixels.length; i++) {
        final p = pixels[i];
        double bestDist = double.infinity;
        int bestK = 0;
        
        for (int j = 0; j < k; j++) {
          final c = centroids[j];
          // Account for circular hue distance + standard value/saturation difference
          double hDist = (p[0] - c[0]).abs();
          if (hDist > 180) hDist = 360 - hDist; 
          
          final currentDist = hDist + (p[1] - c[1]).abs() * 100 + (p[2] - c[2]).abs() * 100;
          if (currentDist < bestDist) {
            bestDist = currentDist;
            bestK = j;
          }
        }
        
        if (assignments[i] != bestK) {
          changed = true;
          assignments[i] = bestK;
        }
        
        newCentroids[bestK][0] += p[0];
        newCentroids[bestK][1] += p[1];
        newCentroids[bestK][2] += p[2];
        counts[bestK]++;
      }

      // Update centroids
      for (int j = 0; j < k; j++) {
        if (counts[j] > 0) {
          centroids[j] = [
            newCentroids[j][0] / counts[j],
            newCentroids[j][1] / counts[j],
            newCentroids[j][2] / counts[j],
          ];
        } else {
          centroids[j] = pixels[rand.nextInt(pixels.length)]; // Respawn empty cluster
        }
      }
    }

    // 5. Find the largest cluster
    List<int> finalCounts = List.filled(k, 0);
    for (int a in assignments) {
      finalCounts[a]++;
    }

    int largestClusterIndex = 0;
    int maxCount = 0;
    for (int i = 0; i < k; i++) {
      if (finalCounts[i] > maxCount) {
        maxCount = finalCounts[i];
        largestClusterIndex = i;
      }
    }

    return centroids[largestClusterIndex];
  }

  // 6. Classify strict heuristic color ranges
  static String _hsvToColorName(double h, double s, double v) {
    if (v < 0.2) return 'Black';
    if (s < 0.15 && v > 0.8) return 'White';
    if (s < 0.2) return 'Grey';
    
    if (h >= 345 || h < 15) return 'Red';
    if (h < 45) {
      if (s > 0.3 && v < 0.6) return 'Brown';
      return 'Orange';
    }
    if (h < 75) return 'Yellow';
    if (h < 150) return 'Green';
    if (h < 260) return 'Blue';
    if (h < 300) return 'Purple';
    if (h < 345) return 'Pink';

    return 'Grey';
  }
}
