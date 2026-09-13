// lib/services/kanji_summary_service.dart
import '../models/kanji_learning_item.dart';
import 'kanji_progress_service.dart';
import 'kanji_unlock_service.dart';

// lib/services/kanji_summary_service.dart
class GroupSummary {
  final int mastered;
  final int inProgress;
  final int locked;
  final int dueNow; // items currently showing up in review
  final int total;

  GroupSummary({
    required this.mastered,
    required this.inProgress,
    required this.locked,
    required this.dueNow,
  }) : total = mastered + inProgress + locked;

  int get percentMastered => total == 0 ? 0 : ((mastered / total) * 100).round();
}

class KanjiSummaryService {
  final KanjiProgressService _progressService;
  final KanjiUnlockService _unlockService;
  KanjiSummaryService(this._progressService, this._unlockService);

  Future<GroupSummary> summarizeGroup(List<KanjiLearningItem> items) async {
    int mastered = 0;
    int inProgress = 0;
    int locked = 0;
    int dueNow = 0;

    final progresses = await _progressService.getProgressFor(items.map((i) => i.id).toList());

    for (final item in items) {
      final isUnlocked = await _unlockService.isItemUnlocked(item);
      if (!isUnlocked) {
        locked++;
        continue;
      }
      final progress = progresses[item.id]!;
      if (_progressService.isMastered(progress)) {
        mastered++;
      } else {
        inProgress++;
      }
      if (_progressService.isDue(progress)) {
        dueNow++;
      }
    }

    return GroupSummary(mastered: mastered, inProgress: inProgress, locked: locked, dueNow: dueNow);
  }
}