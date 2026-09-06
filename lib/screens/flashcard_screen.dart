// lib/screens/flashcard_screen.dart
import 'package:flutter/material.dart';
import '../models/vocab_card.dart';
import '../services/progress_service.dart';

class FlashcardScreen extends StatefulWidget {
  final List<VocabCard> cards;
  const FlashcardScreen({super.key, required this.cards});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final _progressService = ProgressService();
  late List<VocabCard> _shuffledCards;
  int _index = 0;
  bool _showAnswer = false;
  int _correctCount = 0;
  int _wrongCount = 0;

  @override
  void initState() {
    super.initState();
    _shuffledCards = List.of(widget.cards)..shuffle();
  }

  double get _percentage {
    final total = _correctCount + _wrongCount;
    if (total == 0) return 0;
    return (_correctCount / total) * 100;
  }

  void _nextCard() {
    setState(() {
      _showAnswer = false;
      _index++;
      if (_index >= _shuffledCards.length) {
        _index = 0;
        _shuffledCards.shuffle();
      }
    });
  }

  void _markCorrect() {
    final card = _shuffledCards[_index];
    _progressService.markMastered(card.key);
    setState(() => _correctCount++);
    _nextCard();
  }

  void _markWrong() {
    final card = _shuffledCards[_index];
    _progressService.unmarkMastered(card.key); // now un-masters on wrong
    setState(() => _wrongCount++);
    _nextCard();
  }

  @override
  Widget build(BuildContext context) {
    final card = _shuffledCards[_index];
    final total = _correctCount + _wrongCount;

    return Scaffold(
      appBar: AppBar(title: const Text('Vocab Flashcards')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Correct: $_correctCount', style: const TextStyle(color: Colors.green)),
                Text(
                  '${_percentage.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Text('Wrong: $_wrongCount', style: const TextStyle(color: Colors.red)),
              ],
            ),
            const Spacer(),
            Text(card.japanese, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(card.reading, style: const TextStyle(fontSize: 24, color: Colors.grey)),
            const SizedBox(height: 16),
            if (_showAnswer) ...[
              Text(card.meaning, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                card.type,
                style: const TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
            const Spacer(),
            if (!_showAnswer)
              ElevatedButton(
                onPressed: () => setState(() => _showAnswer = true),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  child: Text('Reveal'),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: _markCorrect,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text('Correct', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: _markWrong,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text('Wrong', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            Text('Card ${total + 1} shown so far', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}