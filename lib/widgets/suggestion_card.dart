import 'package:flutter/material.dart';
import '../models/outfit_model.dart';
import '../services/wardrobe_service.dart';

/// A single suggestion card showing an item name, category, and color.
class SuggestionCard extends StatelessWidget {
  final String itemName;
  final String imageUrl; // Kept to avoid breaking existing instantiations
  final String category;
  final String color;
  final String? description;

  const SuggestionCard({
    super.key,
    required this.itemName,
    required this.imageUrl,
    this.category = 'Mix',
    this.color = 'Unknown',
    this.description,
  });

  void _addToWardrobe(BuildContext context) {
    final outfit = Outfit(
      outfitId: DateTime.now().millisecondsSinceEpoch.toString(),
      clothingName: itemName,
      color: color,
      category: category,
      dateAdded: DateTime.now(),
    );
    WardrobeService().addOutfit(outfit);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$itemName added to Wardrobe!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140, // Optimized for horizontal lists while looking good in grid
      margin: const EdgeInsets.only(right: 12), // Kept original margin for consistency
      decoration: BoxDecoration(
        color: const Color(0xFF0F051D), // Maintained dark theme background
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.purpleAccent.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top section with Category, Color, and Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.purpleAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Color Info
                Row(
                  children: [
                    const Icon(Icons.color_lens_outlined, size: 12, color: Colors.white60),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        color,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Clothing Name
                Expanded(
                  child: Text(
                    itemName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Optional Description
                if (description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Add to Wardrobe Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _addToWardrobe(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent.withOpacity(0.15),
                foregroundColor: Colors.purpleAccent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Add to Wardrobe',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
