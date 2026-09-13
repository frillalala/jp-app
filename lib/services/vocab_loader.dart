// lib/services/vocab_loader.dart
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/vocab_card.dart';
import '../config/levels.dart';

Future<List<VocabCard>> loadVocab(String level) async {
  final path = levelAssets[level]!.vocab;
  final raw = await rootBundle.loadString(path);
  final normalized = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final rows = const CsvToListConverter(eol: '\n').convert(normalized);
  return rows.skip(1).map((r) => VocabCard.fromRow(r)).toList();
}

List<String> extractCategories(List<VocabCard> cards) {
  return cards.map((c) => c.category).toSet().toList()..sort();
}