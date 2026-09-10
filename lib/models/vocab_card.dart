// lib/models/vocab_card.dart
class VocabCard {
  final String vid;
  final String japanese;
  final String reading;
  final String meaning;
  final String type;
  final String category;
  final String subCategory;
  final String level;
  final String sampleSentence;
  final String sentenceHiragana;
  final String sentenceMeaning;

  VocabCard({
    required this.vid,
    required this.japanese,
    required this.reading,
    required this.meaning,
    required this.type,
    required this.category,
    required this.subCategory,
    required this.level,
    required this.sampleSentence,
    required this.sentenceHiragana,
    required this.sentenceMeaning,
  });

  factory VocabCard.fromRow(List<dynamic> row) {
    return VocabCard(
      vid: row[0].toString().trim(),
      japanese: row[1].toString().trim(),
      reading: row[2].toString().trim(),
      meaning: row[3].toString().trim(),
      type: row[4].toString().trim(),
      category: row[5].toString().trim(),
      subCategory: row[6].toString().trim(),
      level: row[7].toString().trim(),
      sampleSentence: row.length > 8 ? row[8].toString().trim() : '',
      sentenceHiragana: row.length > 9 ? row[9].toString().trim() : '',
      sentenceMeaning: row.length > 10? row[10].toString().trim() : '',
    );
  }

  String get key => '$japanese|$reading';
}