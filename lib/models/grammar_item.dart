// lib/models/grammar_item.dart
class GrammarItem {
  final String gid;
  final String type; // 'sample' or 'exercise'
  final String grammar; // category name
  final String sentence;
  final String hiragana;
  final String meaning;
  final List<String> words;
  final String description;

  GrammarItem({
    required this.gid,
    required this.type,
    required this.grammar,
    required this.sentence,
    required this.hiragana,
    required this.meaning,
    required this.words,
    required this.description,
  });

  factory GrammarItem.fromRow(List<dynamic> row) {
    final wordsRaw = row[6].toString().trim();
    return GrammarItem(
      gid: row[0].toString().trim(),
      type: row[1].toString().trim(),
      grammar: row[2].toString().trim(),
      sentence: row[3].toString().trim(),
      hiragana: row[4].toString().trim(),
      meaning: row[5].toString().trim(),
      words: wordsRaw.split('|').map((w) => w.trim()).toList(),
      description: row.length > 7 ? row[7].toString().trim() : '',
    );
  }

  bool get isSample => type == 'sample';
  bool get isExercise => type == 'exercise';
}