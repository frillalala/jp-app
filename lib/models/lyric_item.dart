// lib/models/lyric_question.dart
class LyricQuestion {
  final String id;
  final String title;
  final String sentence;
  final String hiragana;
  final String correctOption;
  final String wrongOption1;
  final String wrongOption2;

  LyricQuestion({
    required this.id,
    required this.title,
    required this.sentence,
    required this.hiragana,
    required this.correctOption,
    required this.wrongOption1,
    required this.wrongOption2,
  });

  factory LyricQuestion.fromRow(List<dynamic> row) {
    return LyricQuestion(
      id: row[0].toString().trim(),
      title: row[1].toString().trim(),
      sentence: row[2].toString().trim(),
      hiragana: row[3].toString().trim(),
      correctOption: row[4].toString().trim(),
      wrongOption1: row[5].toString().trim(),
      wrongOption2: row[6].toString().trim(),
    );
  }

  List<String> get shuffledOptions =>
      [correctOption, wrongOption1, wrongOption2]..shuffle();
}