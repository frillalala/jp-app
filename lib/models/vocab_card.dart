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
      japanese: row[0].toString(),
      reading: row[1].toString(),
      meaning: row[2].toString(),
      type: row[3].toString(),
      category: row[4].toString(),
    );
  }

  // Unique key to track mastery per word
  String get key => '$japanese|$reading';
}