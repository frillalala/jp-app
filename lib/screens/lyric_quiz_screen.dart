// lib/screens/lyric_quiz_screen.dart
import 'package:flutter/material.dart';
import '../models/lyric_item.dart';
import '../services/progress_service.dart';

class LyricQuizScreen extends StatefulWidget {
  final String title;
  final List<LyricQuestion> questions;
  const LyricQuizScreen({super.key, required this.title, required this.questions});

  @override
  State<LyricQuizScreen> createState() => _LyricQuizScreenState();
}

class _LyricQuizScreenState extends State<LyricQuizScreen> {
  final _progressService = LyricProgressService();

  List<LyricQuestion> _deck = [];
  List<String> _currentOptions = [];
  int _index = 0;
  bool _loading = true;
  bool _checked = false;
  String? _selected;
  int _correctCount = 0;
  int _wrongCount = 0;

  @override
  void initState() {
    super.initState();
    _buildDeck();
  }

  Future<void> _buildDeck() async {
    final priority = <LyricQuestion>[];
    final mastered = <LyricQuestion>[];

    for (final q in widget.questions) {
      final isMastered = await _progressService.isMastered(q.id);
      (isMastered ? mastered : priority).add(q);
    }
    priority.shuffle();
    mastered.shuffle();

    setState(() {
      _deck = [...priority, ...mastered];
      _index = 0;
      _loading = false;
    });
    _setupCurrentQuestion();
  }

  void _setupCurrentQuestion() {
    setState(() {
      _currentOptions = _deck[_index].shuffledOptions;
      _checked = false;
      _selected = null;
    });
  }

  void _selectOption(String option) {
    if (_checked) return;
    final current = _deck[_index];
    final isCorrect = option == current.correctOption;

    setState(() {
      _selected = option;
      _checked = true;
      isCorrect ? _correctCount++ : _wrongCount++;
    });

    if (isCorrect) {
      _progressService.markMastered(current.id);
    } else {
      _progressService.unmarkMastered(current.id);
    }
  }

  void _nextQuestion() {
    setState(() {
      _index++;
      if (_index >= _deck.length) _index = 0;
    });
    _setupCurrentQuestion();
  }

  double get _percentage {
    final total = _correctCount + _wrongCount;
    return total == 0 ? 0 : (_correctCount / total) * 100;
  }

  Color? _optionColor(String option) {
    if (!_checked) return null;
    final current = _deck[_index];
    if (option == current.correctOption) return Colors.green.shade100;
    if (option == _selected) return Colors.red.shade100;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _deck.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final current = _deck[_index];
    final total = _correctCount + _wrongCount;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Correct: $_correctCount', style: const TextStyle(color: Colors.green)),
                Text('${_percentage.toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                Text('Wrong: $_wrongCount', style: const TextStyle(color: Colors.red)),
              ],
            ),
            const SizedBox(height: 32),
            Text(current.sentence, style: const TextStyle(fontSize: 24), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(current.hiragana, style: const TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 32),

            ..._currentOptions.map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _optionColor(option),
                    ),
                    onPressed: () => _selectOption(option),
                    child: Text(option, style: const TextStyle(fontSize: 18)),
                  ),
                ),
              );
            }),

            if (_checked) ...[
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _nextQuestion, child: const Text('Next')),
            ],

            const SizedBox(height: 16),
            Text('Question ${total + 1} shown so far', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}