// lib/screens/kanji_group_list_screen.dart
import 'package:flutter/material.dart';
import '../models/kanji_learning_item.dart';
import '../models/kanji_item_tier.dart';
import '../services/kanji_progress_service.dart';
import '../services/kanji_unlock_service.dart';
import '../theme/app_theme.dart';
import 'kanji_item_detail_screen.dart';

class KanjiGroupListScreen extends StatefulWidget {
  final KanjiGroup group;
  final List<KanjiLearningItem> items;

  const KanjiGroupListScreen({super.key, required this.group, required this.items});

  @override
  State<KanjiGroupListScreen> createState() => _KanjiGroupListScreenState();
}

class _KanjiGroupListScreenState extends State<KanjiGroupListScreen> {
  final _progressService = KanjiProgressService();
  late final KanjiUnlockService _unlockService;

  bool _loading = true;
  Map<String, ItemTier> _tierByItem = {};
  Map<String, bool> _unlockedByItem = {};

  @override
  void initState() {
    super.initState();
    _unlockService = KanjiUnlockService(_progressService);
    _load();
  }

  Future<void> _load() async {
    final progresses = await _progressService.getProgressFor(
      widget.items.map((i) => i.id).toList(),
    );

    final tiers = <String, ItemTier>{};
    final unlocked = <String, bool>{};

    for (final item in widget.items) {
      tiers[item.id] = progresses[item.id]!.tier;
      unlocked[item.id] = await _unlockService.isItemUnlocked(item);
    }

    setState(() {
      _tierByItem = tiers;
      _unlockedByItem = unlocked;
      _loading = false;
    });
  }

  Color _colorForItem(KanjiLearningItem item) {
    final isUnlocked = _unlockedByItem[item.id] ?? false;
    if (!isUnlocked) return AppColors.tierLocked;

    switch (_tierByItem[item.id]!) {
      case ItemTier.learning:
        return AppColors.tierLearning;
      case ItemTier.bronze:
        return AppColors.tierBronze;
      case ItemTier.silver:
        return AppColors.tierSilver;
      case ItemTier.gold:
        return AppColors.tierGold;
      case ItemTier.platinum:
        return AppColors.tierPlatinum;
    }
  }

  String get _groupTitle {
    switch (widget.group) {
      case KanjiGroup.radical:
        return 'Radicals';
      case KanjiGroup.kanji:
        return 'Kanji';
      case KanjiGroup.vocab:
        return 'Vocab';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(_groupTitle)),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final isUnlocked = _unlockedByItem[item.id] ?? false;

          return GestureDetector(
            onTap: isUnlocked
                ? () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KanjiItemDetailScreen(item: item),
                      ),
                    );
                    _load(); // refresh in case mastery changed via a linked quiz
                  }
                : null,
            child: Container(
              decoration: BoxDecoration(
                color: _colorForItem(item),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: isUnlocked
                  ? Text(
                      item.display,
                      style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  : const Icon(Icons.lock, color: Colors.white70, size: 18),
            ),
          );
        },
      ),
    );
  }
}