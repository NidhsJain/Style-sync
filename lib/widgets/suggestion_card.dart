import 'package:flutter/material.dart';
import '../models/outfit_model.dart';
import '../services/wardrobe_service.dart';

/// A single suggestion card showing an item image and name.
class SuggestionCard extends StatelessWidget {
  final String itemName;
  final String imageUrl;
  final String category;
  final String color;

  const SuggestionCard({
    super.key,
    required this.itemName,
    required this.imageUrl,
    this.category = 'Mix',
    this.color = 'Unknown',
  });

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B0B2E),
        title: Text(itemName, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(imageUrl, height: 200, fit: BoxFit.cover),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close', style: TextStyle(color: Colors.purpleAccent))),
        ],
      ),
    );
  }

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
    return GestureDetector(
      onTap: () => _showDetailDialog(context),
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B0B2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.purpleAccent.withOpacity(0.25),
            width: 1,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image area
            Expanded(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: const Color(0xFF2B0A3D),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.purpleAccent,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF2B0A3D),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white30,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Item label
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: Text(
                itemName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            TextButton(
              onPressed: () => _addToWardrobe(context),
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Add to Wardrobe', style: TextStyle(fontSize: 10, color: Colors.purpleAccent)),
            ),
          ],
        ),
      ),
    );
  }
}
