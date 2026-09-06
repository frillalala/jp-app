// lib/services/progress_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const _masteredKey = 'mastered_words';

  Future<Set<String>> _getMasteredSet() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_masteredKey) ?? [];
    return list.toSet();
  }

  Future<void> markMastered(String wordKey) async {
    final prefs = await SharedPreferences.getInstance();
    final mastered = await _getMasteredSet();
    mastered.add(wordKey);
    await prefs.setStringList(_masteredKey, mastered.toList());
  }

  Future<void> unmarkMastered(String wordKey) async {
    final prefs = await SharedPreferences.getInstance();
    final mastered = await _getMasteredSet();
    mastered.remove(wordKey);
    await prefs.setStringList(_masteredKey, mastered.toList());
  }

  Future<bool> isMastered(String wordKey) async {
    final mastered = await _getMasteredSet();
    return mastered.contains(wordKey);
  }

  Future<int> countMastered(List<String> wordKeys) async {
    final mastered = await _getMasteredSet();
    return wordKeys.where(mastered.contains).length;
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_masteredKey);
  }
}