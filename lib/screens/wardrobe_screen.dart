import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/outfit_model.dart';
import '../services/wardrobe_service.dart';
import 'add_outfit_screen.dart';
import 'edit_outfit_screen.dart';
import 'home_screen.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  static const Color _bg = Color(0xFF0F051D);
  static const Color _card = Color(0xFF1B0B2E);
  final WardrobeService _service = WardrobeService();
  List<Outfit> _outfits = [];

  @override
  void initState() {
    super.initState();
    _loadOutfits();
  }

  void _loadOutfits() {
    setState(() {
      _outfits = _service.getOutfits();
    });
  }

  void _confirmDelete(Outfit outfit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Delete Outfit', style: TextStyle(color: Colors.white)),
          content: Text(
            'Are you sure you want to delete ${outfit.clothingName}?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                _service.deleteOutfit(outfit.outfitId);
                Navigator.pop(context);
                _loadOutfits();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
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
        title: const Text(
          'Wardrobe',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _outfits.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.checkroom, color: Colors.white54, size: 80),
                    const SizedBox(height: 16),
                    const Text(
                      'Your wardrobe is empty.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap + to add an outfit',
                      style: TextStyle(color: Colors.purpleAccent, fontSize: 14),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _outfits.length,
                itemBuilder: (context, index) {
                  final outfit = _outfits[index];
                  // Format date nicely (e.g. YYYY-MM-DD or similar) -> we can just do simple formatting
                  final dateStr = '${outfit.dateAdded.year}-${outfit.dateAdded.month.toString().padLeft(2, '0')}-${outfit.dateAdded.day.toString().padLeft(2, '0')}';
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.purpleAccent.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: outfit.imagePath != null
                                ? (kIsWeb
                                    ? Image.network(
                                        outfit.imagePath!,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(outfit.imagePath!),
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ))
                                : Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.white10,
                                    child: const Icon(Icons.image, color: Colors.white54),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  outfit.clothingName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.color_lens, color: Colors.white54, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      outfit.color,
                                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.category, color: Colors.white54, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      outfit.category,
                                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, color: Colors.white54, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      dateStr,
                                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.purpleAccent),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditOutfitScreen(outfit: outfit),
                                    ),
                                  );
                                  _loadOutfits();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _confirmDelete(outfit),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purpleAccent,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddOutfitScreen()),
          );
          _loadOutfits();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
