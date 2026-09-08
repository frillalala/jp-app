// lib/screens/grammar_category_menu_screen.dart
import 'package:flutter/material.dart';
import '../models/grammar_item.dart';
import '../services/progress_service.dart';
import 'grammar_sample_screen.dart';

class GrammarCategoryMenuScreen extends StatefulWidget {
  final List<GrammarItem> allItems;
  const GrammarCategoryMenuScreen({super.key, required this.allItems});

  @override
  State<GrammarCategoryMenuScreen> createState() => _GrammarCategoryMenuScreenState();
}

class _GrammarCategoryMenuScreenState extends State<GrammarCategoryMenuScreen> {
  final _progressService = GrammarProgressService();
  List<String> _categoryOrder = [];
  Map<String, int> _percentByCategory = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPercentages();
  }

  Future<void> _loadPercentages() async {
    final order = <String>[];
    for (final item in widget.allItems) {
      if (!order.contains(item.grammar)) order.add(item.grammar);
    }

    final result = <String, int>{};
    for (final cat in order) {
      final exercises = widget.allItems.where((i) => i.grammar == cat && i.isExercise).toList();
      if (exercises.isEmpty) {
        result[cat] = 0;
        continue;
      }
      final gids = exercises.map((e) => e.gid).toList();
      final masteredCount = await _progressService.countMastered(gids);
      result[cat] = ((masteredCount / gids.length) * 100).round();
    }

    setState(() {
      _categoryOrder = order;
      _percentByCategory = result;
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
        children: _categoryOrder.map((cat) {
          final percent = _percentByCategory[cat] ?? 0;
          final sample = widget.allItems.firstWhere(
            (i) => i.grammar == cat && i.isSample,
            orElse: () => widget.allItems.firstWhere((i) => i.grammar == cat),
          );
          final exercises = widget.allItems.where((i) => i.grammar == cat && i.isExercise).toList();

          return ListTile(
            title: Text(cat),
            trailing: Text(
              '$percent%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: percent == 100 ? Colors.green : null,
              ),
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GrammarSampleScreen(
                    sample: sample,
                    exercises: exercises,
                    categoryTitle: cat,
                  ),
                ),
              );
              _loadPercentages();
            },
          );
        }).toList(),
      ),
    );
  }
}