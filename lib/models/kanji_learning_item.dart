// lib/models/kanji_learning_item.dart
enum KanjiGroup { radical, kanji, vocab }

class KanjiLearningItem {
  final String id;
  final KanjiGroup group;
  final String level;
  final String display;
  final List<String> prerequisiteIds;
  final Map<String, String> questions;
  final String notes;

  KanjiLearningItem({
    required this.id,
    required this.group,
    required this.level,
    required this.display,
    required this.prerequisiteIds,
    required this.questions,
    required this.notes,
  });
}