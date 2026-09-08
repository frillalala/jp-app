// lib/screens/n5_menu_screen.dart
import 'package:flutter/material.dart';
import 'n5_vocab_category_menu_screen.dart';
import 'n5_grammar_category_menu_screen.dart';
import '../services/vocab_loader.dart';
import '../services/grammar_loader.dart';
import '../services/progress_service.dart';

class N5MenuScreen extends StatefulWidget {
  const N5MenuScreen({super.key});

  @override
  State<N5MenuScreen> createState() => _N5MenuScreenState();
}

class _N5MenuScreenState extends State<N5MenuScreen> {
  final _progressService = ProgressService();
  final _grammarProgressService = GrammarProgressService();
  int? _vocabPercent;
  int? _grammarPercent;

  @override
  void initState() {
    super.initState();
    _loadVocabPercent();
    _loadGrammarPercent();
  }

  Future<void> _loadVocabPercent() async {
    final cards = await loadVocab();
    final keys = cards.map((c) => c.key).toList();
    final masteredCount = await _progressService.countMastered(keys);
    setState(() {
      _vocabPercent = keys.isEmpty ? 0 : ((masteredCount / keys.length) * 100).round();
    });
  }

  Future<void> _loadGrammarPercent() async {
    final items = await loadGrammar();
    final exerciseGids = items.where((i) => i.isExercise).map((i) => i.gid).toList();
    final masteredCount = await _grammarProgressService.countMastered(exerciseGids);
    setState(() {
      _grammarPercent = exerciseGids.isEmpty
          ? 0
          : ((masteredCount / exerciseGids.length) * 100).round();
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Vocab', 'enabled': true},
      {'label': 'Grammar', 'enabled': true},
      {'label': 'Kanji', 'enabled': false},
      {'label': 'Reading', 'enabled': false},
      {'label': 'Listening', 'enabled': false},
      {'label': 'Mock Test', 'enabled': false},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('N5')),
      body: ListView(
        children: items.map((item) {
          final label = item['label'] as String;
          final isEnabled = item['enabled'] as bool;
          final isVocab = label == 'Vocab';
          final isGrammar = label == 'Grammar';

          Widget? trailing;
          if (isVocab && _vocabPercent != null) {
            trailing = Text('$_vocabPercent%', style: const TextStyle(fontWeight: FontWeight.bold));
          } else if (isGrammar && _grammarPercent != null) {
            trailing = Text('$_grammarPercent%', style: const TextStyle(fontWeight: FontWeight.bold));
          } else if (isEnabled) {
            trailing = const Icon(Icons.arrow_forward_ios);
          }

          return ListTile(
            title: Text(label),
            enabled: isEnabled,
            trailing: trailing,
            onTap: !isEnabled
                ? null
                : () async {
                    if (isVocab) {
                      final cards = await loadVocab();
                      if (context.mounted) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryMenuScreen(allCards: cards),
                          ),
                        );
                        _loadVocabPercent();
                      }
                    } else if (isGrammar) {
                      final items = await loadGrammar();
                      if (context.mounted) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GrammarCategoryMenuScreen(allItems: items),
                          ),
                        );
                        _loadGrammarPercent();
                      }
                    }
                  },
          );
        }).toList(),
      ),
    );
  }
}