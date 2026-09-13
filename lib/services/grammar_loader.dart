// lib/services/grammar_loader.dart
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/grammar_item.dart';
import '../config/levels.dart';

Future<List<GrammarItem>> loadGrammar(String level) async {
  final path = levelAssets[level]!.grammar;
  final raw = await rootBundle.loadString(path);
  final normalized = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final rows = const CsvToListConverter(eol: '\n').convert(normalized);
  return rows.skip(1).map((r) => GrammarItem.fromRow(r)).toList();
}