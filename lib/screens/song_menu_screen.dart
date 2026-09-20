// lib/screens/lyric_song_menu_screen.dart
import 'package:flutter/material.dart';
import '../models/lyric_item.dart';
import '../services/progress_service.dart';
import 'lyric_quiz_screen.dart';

class LyricSongMenuScreen extends StatefulWidget {
  final List<LyricQuestion> allQuestions;
  const LyricSongMenuScreen({super.key, required this.allQuestions});

  @override
  State<LyricSongMenuScreen> createState() => _LyricSongMenuScreenState();
}

class _LyricSongMenuScreenState extends State<LyricSongMenuScreen> {
  final _progressService = LyricProgressService();
  List<String> _titleOrder = [];
  Map<String, int> _percentByTitle = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPercentages();
  }

  Future<void> _loadPercentages() async {
    final order = <String>[];
    for (final q in widget.allQuestions) {
      if (!order.contains(q.title)) order.add(q.title);
    }

    final result = <String, int>{};
    for (final title in order) {
      final questions = widget.allQuestions.where((q) => q.title == title).toList();
      final ids = questions.map((q) => q.id).toList();
      final masteredCount = await _progressService.countMastered(ids);
      result[title] = ((masteredCount / ids.length) * 100).round();
    }

    setState(() {
      _titleOrder = order;
      _percentByTitle = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Lyric Study')),
      body: ListView(
        children: _titleOrder.map((title) {
          final percent = _percentByTitle[title]!;
          final questions = widget.allQuestions.where((q) => q.title == title).toList();

          return ListTile(
            title: Text(title),
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
                  builder: (_) => LyricQuizScreen(title: title, questions: questions),
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