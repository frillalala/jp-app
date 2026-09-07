// lib/models/vocab_card.dart
class VocabCard {
  final String vid;
  final String japanese;
  final String reading;
  final String meaning;
  final String type;
  final String category;

  VocabCard({
    required this.vid,
    required this.japanese,
    required this.reading,
    required this.meaning,
    required this.type,
    required this.category,
  });

  factory VocabCard.fromRow(List<dynamic> row) {
    return VocabCard(
      vid: row[0].toString().trim(),
      japanese: row[1].toString().trim(),
      reading: row[2].toString().trim(),
      meaning: row[3].toString().trim(),
      type: row[4].toString().trim(),
      category: row[5].toString().trim(),
    );
  }

  // Unique key to track mastery per word
  String get key => '$japanese|$reading';
}
