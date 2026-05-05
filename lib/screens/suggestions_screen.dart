import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/image_service.dart';
import '../widgets/suggestion_card.dart';
import 'suggestion_list_screen.dart';
import 'wardrobe_screen.dart';
import 'profile_screen.dart';
import 'home_screen.dart';

class SuggestionsScreen extends StatefulWidget {
  final String clothingDescription;
  final String detectedColor;
  final String gender;
  final Map<String, List<String>> outfit;
  final bool usedFallback;

  const SuggestionsScreen({
    super.key,
    required this.clothingDescription,
    required this.detectedColor,
    required this.gender,
    required this.outfit,
    this.usedFallback = false,
  });

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  static const Color _bg = Color(0xFF0F051D);
  static const Color _card = Color(0xFF1B0B2E);
  static const Color _purple = Color(0xFF8A2BE2);

  Color get _tagColor => _getColorFromName(widget.detectedColor);

  Color _getColorFromName(String name) {
    final map = {
      'Red': Colors.red,
      'Dark Red': Colors.red.shade900,
      'Pink': Colors.pink,
      'Orange': Colors.orange,
      'Yellow': Colors.yellow,
      'Lime Yellow': const Color(0xFFC8DC32),
      'Green': Colors.green,
      'Dark Green': Colors.green.shade900,
      'Olive': const Color(0xFF808000),
      'Teal': Colors.teal,
      'Cyan': Colors.cyan,
      'Blue': Colors.blue,
      'Navy Blue': const Color(0xFF000080),
      'Sky Blue': Colors.lightBlue,
      'Purple': Colors.purple,
      'Violet': Colors.deepPurple,
      'Lavender': const Color(0xFFB48CE0),
      'Brown': Colors.brown,
      'Beige': const Color(0xFFD2B48C),
      'Maroon': const Color(0xFF800000),
      'Gray': Colors.grey,
      'Light Gray': Colors.grey.shade300,
      'Dark Gray': Colors.grey.shade700,
      'Black': Colors.grey.shade900,
      'White': Colors.white,
      'Cream': const Color(0xFFFFFDD0),
      'Peach': const Color(0xFFFFC8A0),
      'Mint': const Color(0xFF98FF98),
    };
    return map[name] ?? Colors.purpleAccent;
  }

  Widget _buildSectionHeader(BuildContext context, String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.purpleAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SuggestionListScreen(
                    title: title,
                    items: items,
                    category: title.replaceAll(' Suggestions', ''),
                    detectedColor: widget.detectedColor,
                  ),
                ),
              );
            },
            child: Text(
              'See more',
              style: TextStyle(color: Colors.purpleAccent.withOpacity(0.8), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalSection(BuildContext context, String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, title, items),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return SuggestionCard(
                itemName: item,
                imageUrl: ImageService.getUnsplashUrl(item),
                category: title.replaceAll(' Suggestions', ''),
                color: widget.detectedColor,
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final topwear = widget.outfit['topwear'] ?? [];
    final bottomwear = widget.outfit['bottomwear'] ?? [];
    final footwear = widget.outfit['footwear'] ?? [];
    final accessories = widget.outfit['accessories'] ?? [];
    final jewellery = widget.outfit['jewellery'] ?? [];

    // Build a style summary quote from outfit
    final styleSummaryParts = [...topwear, ...bottomwear, ...footwear];
    final styleSummary = styleSummaryParts.isNotEmpty
        ? '"${widget.gender == 'Female' ? 'Bright colors pair best with neutral and metallic accessories to maintain a balanced and high-end aesthetic.' : 'Neutral colors pair best with neutral and metallic accessories to maintain a balanced and high-end aesthetic.'}"'
        : '';

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen(gender: 'Female')),
                          (route) => false,
                        );
                      }
                    },
                    child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'StyleSync Suggestions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Icon(Icons.share, color: Colors.white, size: 20),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Style title
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Effortless Elegance',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Detected color chip
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: _tagColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white24, width: 1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Detected Top Color: ',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          Text(
                            widget.detectedColor,
                            style: TextStyle(
                              color: _tagColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Fallback notice (only shown when Groq API failed)
                    if (widget.usedFallback)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.amber, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Showing example suggestions — Groq API unavailable.',
                                  style: TextStyle(
                                      color: Colors.amber, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 8),
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.white10,
                    ),

                    const SizedBox(height: 24),

                    // ── SUGGESTION SECTIONS ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (jewellery.isNotEmpty) _buildHorizontalSection(context, 'Jewellery Suggestions', jewellery),
                          if (footwear.isNotEmpty) _buildHorizontalSection(context, 'Footwear Suggestions', footwear),
                          if (accessories.isNotEmpty) _buildHorizontalSection(context, 'Accessories', accessories),
                          if (topwear.isNotEmpty) _buildHorizontalSection(context, 'Topwear Suggestions', topwear),
                          if (bottomwear.isNotEmpty) _buildHorizontalSection(context, 'Bottomwear Suggestions', bottomwear),
                        ],
                      ),
                    ),

                    // Style quote
                    if (styleSummary.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B0B2E),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.purpleAccent.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            styleSummary,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom navigation bar matching Stitch design
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          color: Color(0xFF1B0B2E),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home_outlined, label: 'Home', onTap: () {
              Navigator.popUntil(context, (r) => r.isFirst);
            }),
            _NavItem(icon: Icons.search, label: 'Search'),
            // FAB-like center button
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.purpleAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purpleAccent.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
            _NavItem(icon: Icons.checkroom_outlined, label: 'Outfits', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WardrobeScreen()));
            }),
            _NavItem(icon: Icons.person_outline, label: 'Profile', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            }),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? Colors.purpleAccent : Colors.white54, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.purpleAccent : Colors.white38,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}