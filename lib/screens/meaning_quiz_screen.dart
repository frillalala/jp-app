// lib/screens/meaning_quiz_screen.dart
import 'package:flutter/material.dart';
import '../models/vocab_card.dart';
import '../services/progress_service.dart';

class MeaningQuizScreen extends StatefulWidget {
  final List<VocabCard> cards;
  const MeaningQuizScreen({super.key, required this.cards});

  @override
  State<MeaningQuizScreen> createState() => _MeaningQuizScreenState();
}

class _MeaningQuizScreenState extends State<MeaningQuizScreen> {
  final _progressService = MeaningProgressService();
  final _controller = TextEditingController();

  List<VocabCard> _deck = [];
  int _index = 0;
  bool _loading = true;
  bool _checked = false;
  bool? _isCorrect;
  int _correctCount = 0;
  int _wrongCount = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _buildDeck();
  }

  Future<void> _buildDeck() async {
    final priority = <VocabCard>[];
    final mastered = <VocabCard>[];

    for (final card in widget.cards) {
      final isMastered = await _progressService.isMastered(card.key);
      (isMastered ? mastered : priority).add(card);
    }
    priority.shuffle();
    mastered.shuffle();

    setState(() {
      _deck = [...priority, ...mastered];
      _index = 0;
      _loading = false;
      _checked = false;
      _controller.clear();
    });
  }

  bool _matches(String input) {
    final current = _deck[_index];
    return input.trim().toLowerCase() == current.meaning.trim().toLowerCase();
  }

  void _checkAnswer() {
    final isCorrect = _matches(_controller.text);
    final card = _deck[_index];

    setState(() {
      _checked = true;
      _isCorrect = isCorrect;
      isCorrect ? _correctCount++ : _wrongCount++;
    });

    if (isCorrect) {
      _progressService.markMastered(card.key);
    } else {
      _progressService.unmarkMastered(card.key);
    }
  }

  void _nextCard() {
    setState(() {
      _checked = false;
      _isCorrect = null;
      _controller.clear();
      _index++;
      if (_index >= _deck.length) _index = 0;
    });
  }

  double get _percentage {
    final total = _correctCount + _wrongCount;
    return total == 0 ? 0 : (_correctCount / total) * 100;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _deck.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final card = _deck[_index];
    final total = _correctCount + _wrongCount;

    return Scaffold(
      appBar: AppBar(title: const Text('Meaning Quiz')),
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
            Text(card.japanese, style: const TextStyle(fontSize: 48), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(card.reading, style: const TextStyle(fontSize: 24, color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 32),

            TextField(
              controller: _controller,
              enabled: !_checked,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Type the meaning',
              ),
              onSubmitted: (_) {
                if (!_checked && _controller.text.trim().isNotEmpty) _checkAnswer();
              },
            ),
            const SizedBox(height: 20),

            if (_checked) ...[
              Text(
                _isCorrect! ? 'Correct!' : 'Not quite',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isCorrect! ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text('Answer: ${card.meaning}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _nextCard, child: const Text('Next')),
            ] else
              ElevatedButton(
                onPressed: _controller.text.trim().isEmpty ? null : _checkAnswer,
                child: const Text('Check'),
              ),

            const SizedBox(height: 16),
            Text('Card ${total + 1} shown so far', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}