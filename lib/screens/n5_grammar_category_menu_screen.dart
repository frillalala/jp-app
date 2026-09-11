// lib/screens/grammar_category_menu_screen.dart
import 'package:flutter/material.dart';
import '../models/grammar_item.dart';
import '../services/progress_service.dart';
import 'grammar_category_flow_screen.dart';

class GrammarCategoryMenuScreen extends StatefulWidget {
  final List<GrammarItem> allItems;
  const GrammarCategoryMenuScreen({super.key, required this.allItems});

  @override
  State<GrammarCategoryMenuScreen> createState() => _GrammarCategoryMenuScreenState();
}

class _GrammarCategoryMenuScreenState extends State<GrammarCategoryMenuScreen> {
  final _progressService = GrammarProgressService();

  // category -> ordered list of grammar names within it
  Map<String, List<String>> _grammarsByCategory = {};
  List<String> _categoryOrder = [];

  // grammar name -> percent
  Map<String, int> _percentByGrammar = {};
  // category name -> percent (aggregated across its grammars)
  Map<String, int> _percentByCategory = {};

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPercentages();
  }

  Future<void> _loadPercentages() async {
    final categoryOrder = <String>[];
    final grammarsByCategory = <String, List<String>>{};

    for (final item in widget.allItems) {
      if (!categoryOrder.contains(item.category)) {
        categoryOrder.add(item.category);
        grammarsByCategory[item.category] = [];
      }
      if (!grammarsByCategory[item.category]!.contains(item.grammar)) {
        grammarsByCategory[item.category]!.add(item.grammar);
      }
    }

    final grammarPercents = <String, int>{};
    final categoryPercents = <String, int>{};

    for (final category in categoryOrder) {
      int categoryMastered = 0;
      int categoryTotal = 0;

      for (final grammar in grammarsByCategory[category]!) {
        final exercises = widget.allItems
            .where((i) => i.category == category && i.grammar == grammar && i.isExercise)
            .toList();

        if (exercises.isEmpty) {
          grammarPercents[grammar] = 0;
          continue;
        }

        final gids = exercises.map((e) => e.gid).toList();
        final masteredCount = await _progressService.countMastered(gids);
        grammarPercents[grammar] = ((masteredCount / gids.length) * 100).round();

        categoryMastered += masteredCount;
        categoryTotal += gids.length;
      }

      categoryPercents[category] =
          categoryTotal == 0 ? 0 : ((categoryMastered / categoryTotal) * 100).round();
    }

    setState(() {
      _categoryOrder = categoryOrder;
      _grammarsByCategory = grammarsByCategory;
      _percentByGrammar = grammarPercents;
      _percentByCategory = categoryPercents;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Grammar')),
      body: ListView(
        children: _categoryOrder.expand((category) {
          final catPercent = _percentByCategory[category] ?? 0;
          final grammars = _grammarsByCategory[category] ?? [];

          return [
            // Category header — bigger font, shows aggregated percentage, not tappable
            Container(
              color: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$catPercent%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: catPercent == 100 ? Colors.green : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            // Grammar sub-items
            ...grammars.map((grammar) {
              final percent = _percentByGrammar[grammar] ?? 0;
              final sample = widget.allItems.firstWhere(
                (i) => i.category == category && i.grammar == grammar && i.isSample,
                orElse: () => widget.allItems
                    .firstWhere((i) => i.category == category && i.grammar == grammar),
              );
              final exercises = widget.allItems
                  .where((i) => i.category == category && i.grammar == grammar && i.isExercise)
                  .toList();

              return ListTile(
                contentPadding: const EdgeInsets.only(left: 32, right: 16),
                title: Text(grammar, style: const TextStyle(fontSize: 14)),
                trailing: Text(
                  '$percent%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: percent == 100 ? Colors.green : null,
                  ),
                ),
                onTap: () async {
                  final grammarsInCategory = _grammarsByCategory[category]!;
                  final startIndex = grammarsInCategory.indexOf(grammar);
                  final categoryItems = widget.allItems.where((i) => i.category == category).toList();

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GrammarCategoryFlowScreen(
                        category: category,
                        grammarOrder: grammarsInCategory,
                        allItems: categoryItems,
                        startIndex: startIndex,
                      ),
                    ),
                  );
                  _loadPercentages();
                },
              );
            }),
            const Divider(height: 1, indent: 32),
          ];
        }).toList(),
      ),
    );
  }
}