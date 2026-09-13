// lib/config/levels.dart
const List<String> jlptLevels = ['N5', 'N4', 'N3', 'N2', 'N1'];

class LevelAssets {
  final String vocab;
  final String grammar;
  final String radicals;
  final String kanji;
  final String kanjiVocab;

  const LevelAssets({
    required this.vocab,
    required this.grammar,
    required this.radicals,
    required this.kanji,
    required this.kanjiVocab,
  });
}

// Single source of truth for "what CSV file backs which level".
final Map<String, LevelAssets> levelAssets = {
  for (final level in jlptLevels)
    level: LevelAssets(
      vocab: 'assets/data/${level.toLowerCase()}_vocab.csv',
      grammar: 'assets/data/${level.toLowerCase()}_grammar.csv',
      radicals: 'assets/data/${level.toLowerCase()}_radicals.csv',
      kanji: 'assets/data/${level.toLowerCase()}_kanji.csv',
      kanjiVocab: 'assets/data/${level.toLowerCase()}_kanji_vocab.csv',
    ),
};