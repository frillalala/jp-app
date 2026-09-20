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

class FillBlankProgressService {
  static const _masteredKey = 'mastered_fillblank';

  Future<Set<String>> _getMasteredSet() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_masteredKey) ?? []).toSet();
  }

  Future<void> markMastered(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final mastered = await _getMasteredSet();
    mastered.add(key);
    await prefs.setStringList(_masteredKey, mastered.toList());
  }

  Future<void> unmarkMastered(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final mastered = await _getMasteredSet();
    mastered.remove(key);
    await prefs.setStringList(_masteredKey, mastered.toList());
  }

  Future<bool> isMastered(String key) async {
    return (await _getMasteredSet()).contains(key);
  }

  Future<int> countMastered(List<String> keys) async {
    final mastered = await _getMasteredSet();
    return keys.where(mastered.contains).length;
  }
}

class LyricProgressService {
  static const _masteredKey = 'mastered_lyrics';

  Future<Set<String>> _getMasteredSet() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_masteredKey) ?? []).toSet();
  }

  Future<void> markMastered(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final mastered = await _getMasteredSet();
    mastered.add(id);
    await prefs.setStringList(_masteredKey, mastered.toList());
  }

  Future<void> unmarkMastered(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final mastered = await _getMasteredSet();
    mastered.remove(id);
    await prefs.setStringList(_masteredKey, mastered.toList());
  }

  Future<bool> isMastered(String id) async {
    return (await _getMasteredSet()).contains(id);
  }

  Future<int> countMastered(List<String> ids) async {
    final mastered = await _getMasteredSet();
    return ids.where(mastered.contains).length;
  }
}

class MeaningProgressService {
  static const _masteredKey = 'mastered_meaning';

  Future<Set<String>> _getMasteredSet() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_masteredKey) ?? []).toSet();
  }

  Future<void> markMastered(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final mastered = await _getMasteredSet();
    mastered.add(key);
    await prefs.setStringList(_masteredKey, mastered.toList());
  }

  Future<void> unmarkMastered(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final mastered = await _getMasteredSet();
    mastered.remove(key);
    await prefs.setStringList(_masteredKey, mastered.toList());
  }

  Future<bool> isMastered(String key) async {
    return (await _getMasteredSet()).contains(key);
  }

  Future<int> countMastered(List<String> keys) async {
    final mastered = await _getMasteredSet();
    return keys.where(mastered.contains).length;
  }
}