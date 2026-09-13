// lib/screens/kanji_menu_screen.dart
import 'package:flutter/material.dart';
import '../models/kanji_learning_item.dart';
import '../services/kanji_data_loader.dart';
import '../services/kanji_progress_service.dart';
import '../services/kanji_unlock_service.dart';
import '../services/kanji_summary_service.dart';
import 'kanji_group_list_screen.dart';
import 'kanji_quiz_screen.dart';

class KanjiMenuScreen extends StatefulWidget {
  final String level;
  const KanjiMenuScreen({super.key, required this.level});

  @override
  State<KanjiMenuScreen> createState() => _KanjiMenuScreenState();
}

class _KanjiMenuScreenState extends State<KanjiMenuScreen> {
  final _progressService = KanjiProgressService();
  late final KanjiUnlockService _unlockService;
  late final KanjiSummaryService _summaryService;

  bool _loading = true;
  GroupSummary? _radicalSummary;
  GroupSummary? _kanjiSummary;
  GroupSummary? _vocabSummary;

  List<KanjiLearningItem> _radicals = [];
  List<KanjiLearningItem> _kanji = [];
  List<KanjiLearningItem> _vocab = [];

  @override
  void initState() {
    super.initState();
    _unlockService = KanjiUnlockService(_progressService);
    _summaryService = KanjiSummaryService(_progressService, _unlockService);
    _load();
  }

  Future<void> _load() async {
    final radicals = await loadRadicals(widget.level);
    final kanji = await loadKanji(widget.level);
    final vocab = await loadKanjiVocab(widget.level);

    final radicalSummary = await _summaryService.summarizeGroup(radicals);
    final kanjiSummary = await _summaryService.summarizeGroup(kanji);
    final vocabSummary = await _summaryService.summarizeGroup(vocab);

    setState(() {
      _radicals = radicals;
      _kanji = kanji;
      _vocab = vocab;
      _radicalSummary = radicalSummary;
      _kanjiSummary = kanjiSummary;
      _vocabSummary = vocabSummary;
      _loading = false;
    });
  }

  Future<void> _startReview() async {
    final allItems = [..._radicals, ..._kanji, ..._vocab];
    final dueItems = <KanjiLearningItem>[];

    for (final item in allItems) {
      final isUnlocked = await _unlockService.isItemUnlocked(item);
      if (!isUnlocked) continue;
      final progress = await _progressService.getProgress(item.id);
      if (_progressService.isDue(progress)) dueItems.add(item);
    }

    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => KanjiQuizScreen(dueItems: dueItems)),
      );
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('${widget.level} Kanji')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Current Level: ${widget.level}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          ElevatedButton.icon(
            onPressed: _startReview,
            icon: const Icon(Icons.school),
            label: const Text('Start Review'),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          _buildGroupCard(
            title: 'Radicals',
            summary: _radicalSummary!,
            onTap: () => _openGroup(KanjiGroup.radical, _radicals),
          ),
          const SizedBox(height: 12),
          _buildGroupCard(
            title: 'Kanji',
            summary: _kanjiSummary!,
            onTap: () => _openGroup(KanjiGroup.kanji, _kanji),
          ),
          const SizedBox(height: 12),
          _buildGroupCard(
            title: 'Vocab',
            summary: _vocabSummary!,
            onTap: () => _openGroup(KanjiGroup.vocab, _vocab),
          ),
        ],
      ),
    );
  }

  void _openGroup(KanjiGroup group, List<KanjiLearningItem> items) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KanjiGroupListScreen(group: group, items: items),
      ),
    );
    _load(); // refresh summaries after returning
  }

  Widget _buildGroupCard({
    required String title,
    required GroupSummary summary,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    '${summary.percentMastered}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: summary.percentMastered == 100 ? Colors.green : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _statChip('${summary.mastered} mastered', Colors.green),
                  const SizedBox(width: 8),
                  _statChip('${summary.inProgress} in-progress', Colors.orange),
                  const SizedBox(width: 8),
                  _statChip('${summary.locked} locked', Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(String label, Color color) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact, // use this instead, if you want it tighter
    );
  }
}