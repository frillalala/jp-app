class VocabCard {
  final String japanese;
  final String reading;
  final String meaning;
  final String type;

  VocabCard({
    required this.japanese,
    required this.reading,
    required this.meaning,
    required this.type,
  });

  factory VocabCard.fromRow(List<dynamic> row) {
    return VocabCard(
      japanese: row[0].toString(),
      reading: row[1].toString(),
      meaning: row[2].toString(),
      type: row[3].toString(),
    );
  }
}