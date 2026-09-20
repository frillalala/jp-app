// lib/screens/meaning_category_menu_screen.dart
import 'package:flutter/material.dart';
import '../models/vocab_card.dart';
import '../services/progress_service.dart';
import '../utils/category_labels.dart';
import 'meaning_quiz_screen.dart';

class MeaningCategoryMenuScreen extends StatefulWidget {
  final List<VocabCard> allCards;
  const MeaningCategoryMenuScreen({super.key, required this.allCards});

  @override
  State<MeaningCategoryMenuScreen> createState() => _MeaningCategoryMenuScreenState();
}

class _MeaningCategoryMenuScreenState extends State<MeaningCategoryMenuScreen> {
  final _progressService = MeaningProgressService();
  Map<String, int> _percentByCategory = {};
  int _allPercent = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPercentages();
  }

  Future<void> _loadPercentages() async {
    final categories = widget.allCards.map((c) => c.category).toSet();
    final result = <String, int>{};

    for (final cat in categories) {
      final cardsInCat = widget.allCards.where((c) => c.category == cat).toList();
      final keys = cardsInCat.map((c) => c.key).toList();
      final masteredCount = await _progressService.countMastered(keys);
      result[cat] = ((masteredCount / cardsInCat.length) * 100).round();
    }

    final allKeys = widget.allCards.map((c) => c.key).toList();
    final allMasteredCount = await _progressService.countMastered(allKeys);
    final allPercent = allKeys.isEmpty ? 0 : ((allMasteredCount / allKeys.length) * 100).round();

    setState(() {
      _percentByCategory = result;
      _allPercent = allPercent;
      _loading = false;
    });
  }

  Future<void> _openDeck(List<VocabCard> deck) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MeaningQuizScreen(cards: deck)),
    );
    _loadPercentages();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final categories = _percentByCategory.keys.toList()
      ..sort((a, b) => categoryOrder.indexOf(a).compareTo(categoryOrder.indexOf(b)));

    return Scaffold(
      appBar: AppBar(title: const Text('Meaning Quiz')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('ALL', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text(
              '$_allPercent%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _allPercent == 100 ? Colors.green : null,
              ),
            ),
            onTap: () => _openDeck(widget.allCards),
          ),
          const Divider(),
          ...categories.map((cat) {
            final percent = _percentByCategory[cat]!;
            final cardsInCat = widget.allCards.where((c) => c.category == cat).toList();
            return ListTile(
              title: Text(displayCategory(cat)),
              trailing: Text(
                '$percent%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: percent == 100 ? Colors.green : null,
                ),
              ),
              onTap: () => _openDeck(cardsInCat),
            );
          }),
        ],
      ),
    );
  }
}