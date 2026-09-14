// lib/screens/fillblank_category_menu_screen.dart
import 'package:flutter/material.dart';
import '../models/vocab_card.dart';
import '../services/progress_service.dart';
import '../utils/category_labels.dart';
import 'fillblank_screen.dart';

class FillBlankCategoryMenuScreen extends StatefulWidget {
  final List<VocabCard> allCards;
  const FillBlankCategoryMenuScreen({super.key, required this.allCards});

  @override
  State<FillBlankCategoryMenuScreen> createState() => _FillBlankCategoryMenuScreenState();
}

class _FillBlankCategoryMenuScreenState extends State<FillBlankCategoryMenuScreen> {
  final _progressService = FillBlankProgressService();
  Map<String, int> _percentByCategory = {};
  int _allPercent = 0;
  bool _loading = true;

  // Only cards with a sample sentence are eligible for this lesson type.
  List<VocabCard> get _eligibleCards =>
      widget.allCards.where((c) => c.sampleSentence.isNotEmpty).toList();

  @override
  void initState() {
    super.initState();
    _loadPercentages();
  }

  Future<void> _loadPercentages() async {
    final eligible = _eligibleCards;
    final categories = eligible.map((c) => c.category).toSet();
    final result = <String, int>{};

    for (final cat in categories) {
      final cardsInCat = eligible.where((c) => c.category == cat).toList();
      final keys = cardsInCat.map((c) => c.key).toList();
      final masteredCount = await _progressService.countMastered(keys);
      result[cat] = ((masteredCount / cardsInCat.length) * 100).round();
    }

    final allKeys = eligible.map((c) => c.key).toList();
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
      MaterialPageRoute(builder: (_) => FillBlankScreen(cards: deck)),
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
      appBar: AppBar(title: const Text('Fill in the Blank')),
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
            onTap: () => _openDeck(_eligibleCards),
          ),
          const Divider(),
          ...categories.map((cat) {
            final percent = _percentByCategory[cat]!;
            final cardsInCat = _eligibleCards.where((c) => c.category == cat).toList();
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