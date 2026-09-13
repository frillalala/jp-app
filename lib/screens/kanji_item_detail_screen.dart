// lib/screens/kanji_item_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/kanji_learning_item.dart';
import '../models/kanji_item_tier.dart';
import '../services/kanji_progress_service.dart';
import '../theme/app_theme.dart';

class KanjiItemDetailScreen extends StatefulWidget {
  final KanjiLearningItem item;
  const KanjiItemDetailScreen({super.key, required this.item});

  @override
  State<KanjiItemDetailScreen> createState() => _KanjiItemDetailScreenState();
}

class _KanjiItemDetailScreenState extends State<KanjiItemDetailScreen> {
  final _progressService = KanjiProgressService();
  ItemProgress? _progress;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final progress = await _progressService.getProgress(widget.item.id);
    setState(() => _progress = progress);
  }

  String _tierLabel(ItemTier tier) {
    switch (tier) {
      case ItemTier.learning:
        return 'Learning';
      case ItemTier.bronze:
        return 'Bronze';
      case ItemTier.silver:
        return 'Silver';
      case ItemTier.gold:
        return 'Gold';
      case ItemTier.platinum:
        return 'Platinum';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_progress == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final item = widget.item;

    return Scaffold(
      appBar: AppBar(title: Text(_tierLabel(_progress!.tier))),
      body: Center(
        child: Column(
          children: [
            Text(item.display, style: const TextStyle(fontSize: 64), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ...item.questions.entries.map((entry) {
              return Center(
                // padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    Text(entry.key, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    Text(entry.value, style: const TextStyle(fontSize: 20)),
                  ],
                ),
              );
            }),
            if (item.notes.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Text(item.notes, style: const TextStyle(fontSize: 15), textAlign: TextAlign.center),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}