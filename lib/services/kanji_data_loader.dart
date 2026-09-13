// lib/services/kanji_data_loader.dart
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/kanji_learning_item.dart';
import '../config/levels.dart';

// lib/services/kanji_data_loader.dart
Future<List<List<dynamic>>> _loadCsvRows(String path) async {
  final raw = await rootBundle.loadString(path);
  final normalized = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final rows = const CsvToListConverter(eol: '\n').convert(normalized);
  final dataRows = rows.skip(1); // drop header

  // Skip any row that's empty or has a blank first column (id) —
  // guards against trailing blank lines in the CSV file.
  return dataRows
      .where((r) => r.isNotEmpty && r[0].toString().trim().isNotEmpty)
      .toList();
}

Future<List<KanjiLearningItem>> loadRadicals(String level) async {
  final rows = await _loadCsvRows(levelAssets[level]!.radicals);
  return rows.map((r) {
    final rawId = r[0].toString().trim();
    return KanjiLearningItem(
      id: '${level}_$rawId',
      group: KanjiGroup.radical,
      display: r[1].toString().trim(),
      prerequisiteIds: [], // radicals have no prerequisites
      questions: {'Name': r[2].toString().trim()},
      level: r[3].toString().trim(),
      notes: r.length > 4 ? r[4].toString().trim() : '',
    );
  }).toList();
}

Future<List<KanjiLearningItem>> loadKanji(String level) async {
  final rows = await _loadCsvRows(levelAssets[level]!.kanji);
  return rows.map((r) {
    final rawId = r[0].toString().trim();
    final radicalsRaw = r[5].toString().trim();
    return KanjiLearningItem(
      id: '${level}_$rawId',
      group: KanjiGroup.kanji,
      display: r[1].toString().trim(),
      prerequisiteIds: radicalsRaw.isEmpty
          ? []
          : radicalsRaw.split('|').map((s) => '${level}_${s.trim()}').toList(),
      questions: {
        'Onyomi': r[2].toString().trim(),
        'Kunyomi': r[3].toString().trim(),
        'Meaning': r[4].toString().trim(),
      },
      level: level,
      notes: r.length > 7 ? r[7].toString().trim() : '',
    );
  }).toList();
}

Future<List<KanjiLearningItem>> loadKanjiVocab(String level) async {
  final rows = await _loadCsvRows(levelAssets[level]!.kanjiVocab);
  return rows.map((r) {
    final rawId = r[0].toString().trim();
    final kanjiRaw = r[4].toString().trim();
    return KanjiLearningItem(
      id: '${level}_$rawId',
      group: KanjiGroup.vocab,
      display: r[1].toString().trim(),
      prerequisiteIds: kanjiRaw.isEmpty
          ? []
          : kanjiRaw.split('|').map((s) => '${level}_${s.trim()}').toList(), 
      questions: {
        'Reading': r[2].toString().trim(),
        'Meaning': r[3].toString().trim(),
      },
      level: r[5].toString().trim(),
      notes: r.length > 6 ? r[6].toString().trim() : '',
    );
  }).toList();
}