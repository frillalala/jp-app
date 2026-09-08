// lib/models/grammar_item.dart
class GrammarItem {
  final String gid;
  final String type; // 'sample' or 'exercise'
  final String category; // umbrella group, e.g. "Particles"
  final String grammar; // sub-item, e.g. "の (no) - possessive"
  final String sentence;
  final String hiragana;
  final String meaning;
  final List<String> words;
  final String description;

  GrammarItem({
    required this.gid,
    required this.type,
    required this.category,
    required this.grammar,
    required this.sentence,
    required this.hiragana,
    required this.meaning,
    required this.words,
    required this.description,
  });

  factory GrammarItem.fromRow(List<dynamic> row) {
    final wordsRaw = row[7].toString().trim();
    return GrammarItem(
      gid: row[0].toString().trim(),
      type: row[1].toString().trim(),
      category: row[2].toString().trim(),
      grammar: row[3].toString().trim(),
      sentence: row[4].toString().trim(),
      hiragana: row[5].toString().trim(),
      meaning: row[6].toString().trim(),
      words: wordsRaw.split('|').map((w) => w.trim()).toList(),
      description: row.length > 8 ? row[8].toString().trim() : '',
    );
  }

  bool get isSample => type == 'sample';
  bool get isExercise => type == 'exercise';
}