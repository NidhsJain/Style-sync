import 'package:flutter/material.dart';
import '../widgets/suggestion_card.dart';
import '../services/image_service.dart';
import 'home_screen.dart';

class SuggestionListScreen extends StatelessWidget {
  final String title;
  final List<String> items;
  final String category;
  final String detectedColor;

  const SuggestionListScreen({
    super.key,
    required this.title,
    required this.items,
    required this.category,
    required this.detectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F051D),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () {
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
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return SuggestionCard(
            itemName: items[index],
            imageUrl: ImageService.getUnsplashUrl(items[index]),
            category: category,
            color: detectedColor,
          );
        },
      ),
    );
  }
}
