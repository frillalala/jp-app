import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/vocab_card.dart';

Future<List<VocabCard>> loadVocab() async {
  final raw = await rootBundle.loadString('assets/data/vocab.csv');
  final rows = const CsvToListConverter(eol: '\n').convert(raw, eol: '\n');
  return rows.skip(1).map((r) => VocabCard.fromRow(r)).toList();
}