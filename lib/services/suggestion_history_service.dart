import '../models/suggestion_history_model.dart';

class SuggestionHistoryService {
  static final SuggestionHistoryService _instance = SuggestionHistoryService._internal();

  factory SuggestionHistoryService() {
    return _instance;
  }

  SuggestionHistoryService._internal();

  final List<SuggestionHistory> _history = [];

  List<SuggestionHistory> getHistory() {
    return _history.reversed.toList(); // most recent first
  }

  void saveHistory(SuggestionHistory history) {
    _history.add(history);
  }
}
