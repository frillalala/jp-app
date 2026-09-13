// lib/services/kanji_progress_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kanji_item_tier.dart';

class ItemProgress {
  ItemTier tier;
  int roundStreak;
  DateTime? lastAskedAt;

  ItemProgress({this.tier = ItemTier.learning, this.roundStreak = 0, this.lastAskedAt});

  Map<String, dynamic> toJson() => {
        'tier': tier.index,
        'roundStreak': roundStreak,
        'lastAskedAt': lastAskedAt?.millisecondsSinceEpoch,
      };

  factory ItemProgress.fromJson(Map<String, dynamic> json) => ItemProgress(
        tier: ItemTier.values[json['tier'] as int],
        roundStreak: json['roundStreak'] as int,
        lastAskedAt: json['lastAskedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['lastAskedAt'] as int)
            : null,
      );
}

class KanjiProgressService {
  static const _storageKey = 'kanji_learning_progress';

  Future<Map<String, ItemProgress>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, ItemProgress.fromJson(v as Map<String, dynamic>)));
  }

  Future<void> _saveAll(Map<String, ItemProgress> all) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(all.map((k, v) => MapEntry(k, v.toJson())));
    await prefs.setString(_storageKey, encoded);
  }

  Future<ItemProgress> getProgress(String itemId) async {
    final all = await _loadAll();
    return all[itemId] ?? ItemProgress();
  }

  Future<Map<String, ItemProgress>> getProgressFor(List<String> itemIds) async {
    final all = await _loadAll();
    return {for (final id in itemIds) id: all[id] ?? ItemProgress()};
  }

  /// Call once after a full review round for an item.
  /// [allCorrect] = every question for this item was answered correctly this round.
  Future<ItemProgress> recordResult(String itemId, bool allCorrect) async {
    final all = await _loadAll();
    final progress = all[itemId] ?? ItemProgress();

    if (allCorrect) {
      progress.roundStreak++;
      final threshold = tierAdvanceThreshold[progress.tier];
      if (threshold != null && progress.roundStreak >= threshold) {
        progress.tier = ItemTier.values[progress.tier.index + 1];
        progress.roundStreak = 0;
      }
    } else {
      // No demotion — just reset progress toward the next tier.
      progress.roundStreak = 0;
    }
    progress.lastAskedAt = DateTime.now();

    all[itemId] = progress;
    await _saveAll(all);
    return progress;
  }

  bool isDue(ItemProgress progress) {
    if (progress.tier == ItemTier.platinum) return false;
    if (progress.lastAskedAt == null) return true;
    final interval = tierIntervals[progress.tier]!;
    if (interval == Duration.zero) return true;
    return DateTime.now().difference(progress.lastAskedAt!) >= interval;
  }

  // Mastered = Bronze or higher, per your definition.
  bool isMastered(ItemProgress progress) => progress.tier.index >= ItemTier.bronze.index;

  // Unlock eligibility for dependents uses the same threshold as "mastered".
  bool isUnlockEligible(ItemProgress progress) => isMastered(progress);
}