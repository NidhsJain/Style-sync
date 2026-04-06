class SuggestionHistory {
  final String id;
  final String clothingDescription;
  final Map<String, List<String>> suggestions;
  final DateTime dateTime;

  SuggestionHistory({
    required this.id,
    required this.clothingDescription,
    required this.suggestions,
    required this.dateTime,
  });
}
