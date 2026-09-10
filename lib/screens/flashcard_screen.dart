// lib/screens/flashcard_screen.dart
import 'package:flutter/material.dart';
import '../models/vocab_card.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class FlashcardScreen extends StatefulWidget {
  final List<VocabCard> cards;
  const FlashcardScreen({super.key, required this.cards});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final _progressService = ProgressService();
  List<VocabCard> _deck = [];
  int _index = 0;
  bool _showAnswer = false;
  bool _loading = true;
  bool _isMastered = false;
  int _correctCount = 0;
  int _wrongCount = 0;

  @override
  void initState() {
    super.initState();
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
      _showAnswer = false;
    });
    _loadMasteryForCurrentCard();
  }

  Future<void> _loadMasteryForCurrentCard() async {
    if (_deck.isEmpty) return;
    final mastered = await _progressService.isMastered(_deck[_index].key);
    setState(() => _isMastered = mastered);
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
      if (_index >= _deck.length) _index = 0;
    });
    _loadMasteryForCurrentCard();
  }

  void _markGotIt() {
    setState(() => _correctCount++);
    _nextCard();
  }

  void _markAgain() {
    setState(() => _wrongCount++);
    _nextCard();
  }

  Future<void> _toggleMastery() async {
    final card = _deck[_index];
    if (_isMastered) {
      await _progressService.unmarkMastered(card.key);
    } else {
      await _progressService.markMastered(card.key);
    }
    setState(() => _isMastered = !_isMastered);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _deck.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final card = _deck[_index];
    final total = _correctCount + _wrongCount;

    return Scaffold(
      appBar: AppBar(title: const Text('Vocab Flashcards')),
      body: SingleChildScrollView(
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
            const SizedBox(height: 32),
            Text(card.japanese, style: const TextStyle(fontSize: 48), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(card.reading, style: const TextStyle(fontSize: 24, color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 16),

            // Mastery toggle — deliberately subdued, separate from session actions
            TextButton.icon(
              onPressed: _toggleMastery,
              icon: Icon(
                _isMastered ? Icons.check_circle : Icons.check_circle_outline,
                color: AppColors.mastery,
                size: 20,
              ),
              label: Text(
                _isMastered ? 'Mastered' : 'Mark as mastered',
                style: const TextStyle(color: AppColors.mastery, fontSize: 12),
              ),
            ),

            if (_showAnswer) ...[
              const Divider(),
              const SizedBox(height: 20),
              Text(card.meaning, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              if (card.sampleSentence.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(card.sampleSentence, style: const TextStyle(fontSize: 20), textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text(card.sentenceHiragana, style: const TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text(card.sentenceMeaning, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
              ],
            ],

            const SizedBox(height: 32),

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
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.again),
                    onPressed: _markAgain,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text('Again', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gotIt),
                    onPressed: _markGotIt,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text('Got it', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),
            Text('Card ${total + 1} shown so far', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}