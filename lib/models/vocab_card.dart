// lib/models/vocab_card.dart
class VocabCard {
  final String japanese;
  final String reading;
  final String meaning;
  final String type;
  final String category;

  VocabCard({
    required this.japanese,
    required this.reading,
    required this.meaning,
    required this.type,
    required this.category,
  });

  factory VocabCard.fromRow(List<dynamic> row) {
    return VocabCard(
      japanese: row[0].toString().trim(),
      reading: row[1].toString().trim(),
      meaning: row[2].toString().trim(),
      type: row[3].toString().trim(),
      category: row[4].toString().trim(),
    );
  }

  // Unique key to track mastery per word
  String get key => '$japanese|$reading';
}