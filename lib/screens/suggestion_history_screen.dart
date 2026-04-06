import 'package:flutter/material.dart';
import '../models/suggestion_history_model.dart';
import '../services/suggestion_history_service.dart';
import 'suggestions_screen.dart';
import 'home_screen.dart';

class SuggestionHistoryScreen extends StatelessWidget {
  final String gender;
  const SuggestionHistoryScreen({super.key, required this.gender});

  @override
  Widget build(BuildContext context) {
    final history = SuggestionHistoryService().getHistory();

    return Scaffold(
      backgroundColor: const Color(0xFF0F051D),
      appBar: AppBar(
        title: const Text('Suggestion History'),
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
      body: history.isEmpty
          ? const Center(
              child: Text(
                'No suggestion history yet.',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                
                return Card(
                  color: const Color(0xFF1B0B2E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.purpleAccent.withOpacity(0.2)),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      item.clothingDescription,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${item.dateTime.day}/${item.dateTime.month}/${item.dateTime.year} at ${item.dateTime.hour}:${item.dateTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SuggestionsScreen(
                              clothingDescription: item.clothingDescription,
                              detectedColor: item.clothingDescription.split(' ').first,
                              gender: gender,
                              outfit: item.suggestions,
                              usedFallback: false,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('View Suggestions'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
