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

class GrammarProgressService {
  static const _masteredKey = 'mastered_grammar_exercises';

  Future<Set<String>> _getMasteredSet() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_masteredKey) ?? []).toSet();
  }

  Future<void> markMastered(String gid) async {
    final prefs = await SharedPreferences.getInstance();
    final mastered = await _getMasteredSet();
    mastered.add(gid);
    await prefs.setStringList(_masteredKey, mastered.toList());
  }

  Future<void> unmarkMastered(String gid) async {
    final prefs = await SharedPreferences.getInstance();
    final mastered = await _getMasteredSet();
    mastered.remove(gid);
    await prefs.setStringList(_masteredKey, mastered.toList());
  }

  Future<bool> isMastered(String gid) async {
    return (await _getMasteredSet()).contains(gid);
  }

  Future<int> countMastered(List<String> gids) async {
    final mastered = await _getMasteredSet();
    return gids.where(mastered.contains).length;
  }
}