// lib/screens/n5_menu_screen.dart
import 'package:flutter/material.dart';
import 'vocab_category_menu_screen.dart';
import 'grammar_category_menu_screen.dart';
import 'kanji_menu_screen.dart';
import 'fillblank_menu_screen.dart';
import '../services/vocab_loader.dart';
import '../services/grammar_loader.dart';
import '../services/kanji_data_loader.dart';
import '../services/progress_service.dart';
import '../services/kanji_progress_service.dart';
import '../services/kanji_unlock_service.dart';
import '../services/kanji_summary_service.dart';

class LevelMenuScreen extends StatefulWidget {
  final String level;
  const LevelMenuScreen({super.key, required this.level});

  @override
  State<LevelMenuScreen> createState() => _LevelMenuScreenState();
}

class _LevelMenuScreenState extends State<LevelMenuScreen> {
  final _progressService = ProgressService();
  final _grammarProgressService = GrammarProgressService();
  final _kanjiProgressService = KanjiProgressService();
  final _fillBlankProgressService = FillBlankProgressService();
  late final KanjiUnlockService _kanjiUnlockService;
  late final KanjiSummaryService _kanjiSummaryService;
  int? _vocabPercent;
  int? _grammarPercent;
  int? _kanjiPercent;
  int? _fillBlankPercent;

  @override
  void initState() {
    super.initState();
    _kanjiUnlockService = KanjiUnlockService(_kanjiProgressService);
    _kanjiSummaryService = KanjiSummaryService(_kanjiProgressService, _kanjiUnlockService);
    _loadVocabPercent();
    _loadGrammarPercent();
    _loadKanjiPercent();
    _loadFillBlankPercent();
  }

  Future<void> _loadVocabPercent() async {
    final cards = await loadVocab(widget.level);
    final keys = cards.map((c) => c.key).toList();
    final masteredCount = await _progressService.countMastered(keys);
    setState(() {
      _vocabPercent = keys.isEmpty ? 0 : ((masteredCount / keys.length) * 100).round();
    });
  }

  Future<void> _loadGrammarPercent() async {
    final items = await loadGrammar(widget.level); // pass level through
    final exerciseGids = items.where((i) => i.isExercise).map((i) => i.gid).toList();
    final masteredCount = await _grammarProgressService.countMastered(exerciseGids);
    setState(() {
      _grammarPercent = exerciseGids.isEmpty
          ? 0
          : ((masteredCount / exerciseGids.length) * 100).round();
    });
  }

  Future<void> _loadKanjiPercent() async {
    final radicals = await loadRadicals(widget.level);
    final kanji = await loadKanji(widget.level);
    final vocab = await loadKanjiVocab(widget.level);

    final radicalSummary = await _kanjiSummaryService.summarizeGroup(radicals);
    final kanjiSummary = await _kanjiSummaryService.summarizeGroup(kanji);
    final vocabSummary = await _kanjiSummaryService.summarizeGroup(vocab);

    final totalMastered = radicalSummary.mastered + kanjiSummary.mastered + vocabSummary.mastered;
    final totalItems = radicalSummary.total + kanjiSummary.total + vocabSummary.total;

    setState(() {
      _kanjiPercent = totalItems == 0 ? 0 : ((totalMastered / totalItems) * 100).round();
    });
  }

  Future<void> _loadFillBlankPercent() async {
    final cards = await loadVocab(widget.level);
    final keys = cards.map((c) => c.key).toList();
    final masteredCount = await _fillBlankProgressService.countMastered(keys);
    setState(() {
      _fillBlankPercent = keys.isEmpty ? 0 : ((masteredCount / keys.length) * 100).round();
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Vocab: Flashcards', 'enabled': true},      
      {'label': 'Vocab: Fill in the Blank', 'enabled': true},
      {'label': 'Grammar', 'enabled': true},
      {'label': 'Kanji', 'enabled': true},
      {'label': 'Reading', 'enabled': false},
      {'label': 'Listening', 'enabled': false},
      {'label': 'Mock Test', 'enabled': false},
    ];

    return Scaffold(
      appBar: AppBar(title: Text(widget.level)),
      body: ListView(
        children: items.map((item) {
          final label = item['label'] as String;
          final isEnabled = item['enabled'] as bool;
          final isVocab = label == 'Vocab: Flashcards';
          final isVocalFillBlank = label == 'Vocab: Fill in the Blank';
          final isGrammar = label == 'Grammar';

          Widget? trailing;
          if (isVocab && _vocabPercent != null) {
            trailing = Text('$_vocabPercent%', style: const TextStyle(fontWeight: FontWeight.bold));
          } else if (isGrammar && _grammarPercent != null) {
            trailing = Text('$_grammarPercent%', style: const TextStyle(fontWeight: FontWeight.bold));
          } else if (label == 'Kanji' && _kanjiPercent != null) {
            trailing = Text('$_kanjiPercent%', style: const TextStyle(fontWeight: FontWeight.bold));
          } else if (isVocalFillBlank && _fillBlankPercent != null) {
            trailing = Text('$_fillBlankPercent%', style: const TextStyle(fontWeight: FontWeight.bold));  
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
                    // final cards = await loadVocab(widget.level);
                    if (isVocab) {
                      final cards = await loadVocab(widget.level);
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
                      final items = await loadGrammar(widget.level);
                      if (context.mounted) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GrammarCategoryMenuScreen(allItems: items),
                          ),
                        );
                        _loadGrammarPercent();
                      }
                    } else if (label == 'Kanji') {
                      if (context.mounted) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => KanjiMenuScreen(level: widget.level),
                          ),
                        );
                        _loadKanjiPercent();
                      }
                    } else if (isVocalFillBlank) {
                      final cards = await loadVocab(widget.level);
                      if (context.mounted) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => FillBlankCategoryMenuScreen(allCards: cards)),
                        );
                        _loadFillBlankPercent(); // add a matching _loadFillBlankPercent(), mirroring _loadVocabPercent
                      }
                    }
                  },
          );
        }).toList(),
      ),
    );
  }
}