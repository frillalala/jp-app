// lib/services/lyric_loader.dart
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/lyric_item.dart';
import '../config/levels.dart';

Future<List<LyricQuestion>> loadLyrics(String level) async {
  final raw = await rootBundle.loadString(levelAssets[level]!.lyrics);
  final normalized = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final rows = const CsvToListConverter(eol: '\n').convert(normalized);
  final dataRows = rows.skip(1).where((r) => r.isNotEmpty && r[0].toString().trim().isNotEmpty);
  return dataRows.map((r) => LyricQuestion.fromRow(r)).toList();
}