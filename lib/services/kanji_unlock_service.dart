// lib/services/kanji_unlock_service.dart
import '../models/kanji_learning_item.dart';
import '../config/levels.dart';
import 'kanji_progress_service.dart';

const levelUnlockThreshold = 0.8; // 80% of a level's items at Bronze+ unlocks the next level

class KanjiUnlockService {
  final KanjiProgressService _progressService;
  KanjiUnlockService(this._progressService);

  /// Is this specific item unlocked? Radicals (no prerequisites) are always
  /// unlocked once their level is accessible. Kanji/vocab need every
  /// prerequisite to be Bronze+.
  Future<bool> isItemUnlocked(KanjiLearningItem item) async {
    if (item.prerequisiteIds.isEmpty) return true;
    final progresses = await _progressService.getProgressFor(item.prerequisiteIds);
    return progresses.values.every((p) => _progressService.isMastered(p));
  }

  /// Returns the set of levels currently accessible for the Kanji feature,
  /// starting from N5. A level unlocks once >= 80% of the *previous* level's
  /// combined radical+kanji+vocab items are Bronze+.
  Future<List<String>> computeUnlockedLevels({
    required Future<List<KanjiLearningItem>> Function(String level) loadRadicals,
    required Future<List<KanjiLearningItem>> Function(String level) loadKanji,
    required Future<List<KanjiLearningItem>> Function(String level) loadKanjiVocab,
  }) async {
    final unlocked = <String>[jlptLevels.first];

    for (var i = 0; i < jlptLevels.length - 1; i++) {
      final level = jlptLevels[i];
      final allItems = [
        ...await loadRadicals(level),
        ...await loadKanji(level),
        ...await loadKanjiVocab(level),
      ];
      if (allItems.isEmpty) break;

      final progresses = await _progressService.getProgressFor(
        allItems.map((it) => it.id).toList(),
      );
      final bronzePlusCount = progresses.values.where((p) => _progressService.isMastered(p)).length;
      final ratio = bronzePlusCount / allItems.length;

      if (ratio >= levelUnlockThreshold) {
        unlocked.add(jlptLevels[i + 1]);
      } else {
        break;
      }
    }
    return unlocked;
  }
}