import 'package:flutter/material.dart';
import '../services/clothing_detection_service.dart';
import '../services/outfit_ai_service.dart';
import '../services/avatar_generation_service.dart';
import 'suggestions_screen.dart';

/// Orchestrates the full pipeline:
/// ClothingDetection → Groq API → HuggingFace Avatar → SuggestionsScreen
class AnalyzeScreen extends StatefulWidget {
  final String imagePath;
  final String gender;

  const AnalyzeScreen({
    super.key,
    required this.imagePath,
    required this.gender,
  });

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String _statusText = 'Analyzing color compatibility...';
  double _progress = 0.0;

  // ── Fallback suggestions used when Groq API fails ──────────────────────────
  static const Map<String, List<String>> _fallbackSuggestions = {
    'topwear': ['White linen shirt', 'Beige polo shirt'],
    'bottomwear': ['Beige chinos', 'Light grey trousers'],
    'footwear': ['White sneakers', 'Tan loafers'],
    'accessories': ['Brown leather belt', 'Classic sunglasses'],
    'jewellery': ['Silver watch', 'Simple bracelet'],
  };

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _runPipeline();
  }

  Future<void> _runPipeline() async {
    // ── STEP 1: Clothing Detection ─────────────────────────────────────────
    _setStatus('Scanning clothing color and type...', 0.1);

    Map<String, String> detection = {
      'color': 'Unknown',
      'type': 'Shirt',
      'description': 'Unknown Shirt',
    };

    try {
      detection = await ClothingDetectionService.analyzeClothing(widget.imagePath);
      debugPrint('═══ CLOTHING DETECTION ═══');
      debugPrint('  Color    : ${detection['color']}');
      debugPrint('  Type     : ${detection['type']}');
      debugPrint('  Description: ${detection['description']}');
    } catch (e) {
      debugPrint('⚠ Clothing detection failed: $e — using defaults');
    }

    final clothingDescription = detection['description'] ?? 'Unknown Shirt';
    final detectedColor = detection['color'] ?? 'Unknown';

    // ── STEP 2: Groq API — Outfit Suggestions ─────────────────────────────
    _setStatus('Generating outfit suggestions with AI...', 0.35);

    Map<String, List<String>> outfit = _fallbackSuggestions;
    bool usedFallback = false;

    try {
      debugPrint('═══ GROQ API REQUEST ═══');
      debugPrint('  Clothing : $clothingDescription');
      debugPrint('  Gender   : ${widget.gender}');

      outfit = await OutfitAIService.getSuggestions(
        clothingDescription: clothingDescription,
        gender: widget.gender,
      );

      debugPrint('═══ GROQ API RESPONSE ═══');
      outfit.forEach((key, value) => debugPrint('  $key: $value'));
    } catch (e) {
      debugPrint('⚠ Groq API failed: $e — using fallback suggestions');
      usedFallback = true;
    }

    // ── STEP 3: HuggingFace — Avatar Generation ───────────────────────────
    _setStatus('Generating your full-body avatar...', 0.65);

    dynamic avatarBytes;

    try {
      debugPrint('═══ AVATAR GENERATION ═══');
      debugPrint('  Gender   : ${widget.gender}');
      debugPrint('  Clothing : $clothingDescription');

      avatarBytes = await AvatarGenerationService.generateAvatar(
        gender: widget.gender,
        outfit: outfit,
        detectedClothing: clothingDescription,
      );

      if (avatarBytes != null) {
        debugPrint('✓ Avatar generated — ${avatarBytes.length} bytes');
      } else {
        debugPrint('⚠ Avatar generation returned null (token missing or model error)');
      }
    } catch (e) {
      debugPrint('⚠ Avatar generation failed: $e');
      avatarBytes = null;
    }

    // ── STEP 4: Navigate to SuggestionsScreen ────────────────────────────
    _setStatus(
      usedFallback ? 'Using fallback suggestions.' : 'Analysis complete!',
      1.0,
    );

    debugPrint('═══ PIPELINE COMPLETE ═══');
    debugPrint('  Fallback used : $usedFallback');
    debugPrint('  Avatar loaded : ${avatarBytes != null}');

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SuggestionsScreen(
          clothingDescription: clothingDescription,
          detectedColor: detectedColor,
          gender: widget.gender,
          outfit: outfit,
          avatarBytes: avatarBytes,
          usedFallback: usedFallback,
        ),
      ),
    );
  }

  void _setStatus(String text, double progress) {
    if (mounted) {
      setState(() {
        _statusText = text;
        _progress = progress;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F051D),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing icon
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFF8A2BE2), Color(0xFF4B0082)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent.withValues(alpha: 0.5),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Text(
                _statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Scanning textures and tones to find\nyour perfect match.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),

              const SizedBox(height: 32),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  backgroundColor: const Color(0xFF2B0A3D),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.purpleAccent,
                  ),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 12),

              if (_progress > 0)
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }
}