// lib/screens/kanji_quiz_screen.dart
import 'package:flutter/material.dart';
import '../models/kanji_learning_item.dart';
import '../services/kanji_progress_service.dart';
import '../theme/app_theme.dart';

class _QuizPrompt {
  final KanjiLearningItem item;
  final String questionLabel;
  final String correctAnswerRaw; // may contain pipe-separated alternatives
  _QuizPrompt(this.item, this.questionLabel, this.correctAnswerRaw);
}

class KanjiQuizScreen extends StatefulWidget {
  final List<KanjiLearningItem> dueItems;
  const KanjiQuizScreen({super.key, required this.dueItems});

  @override
  State<KanjiQuizScreen> createState() => _KanjiQuizScreenState();
}

class _KanjiQuizScreenState extends State<KanjiQuizScreen> {
  final _progressService = KanjiProgressService();
  final _controller = TextEditingController();

  List<_QuizPrompt> _prompts = [];
  int _promptIndex = 0;

  // itemId -> how many of its prompts remain unanswered in this session
  final Map<String, int> _remainingPromptsForItem = {};
  // itemId -> whether every prompt answered so far for this item was correct
  final Map<String, bool> _allCorrectForItem = {};

  bool _checked = false;
  bool? _isCorrect;
  int _correctCount = 0;
  int _wrongCount = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _buildPrompts();
  }

  void _buildPrompts() {
    final prompts = <_QuizPrompt>[];
    for (final item in widget.dueItems) {
      for (final entry in item.questions.entries) {
        prompts.add(_QuizPrompt(item, entry.key, entry.value));
      }
      _remainingPromptsForItem[item.id] = item.questions.length;
      _allCorrectForItem[item.id] = true;
    }
    prompts.shuffle();
    setState(() {
      _prompts = prompts;
      _promptIndex = 0;
    });
  }

  bool _matches(String input, String correctRaw) {
    final validAnswers = correctRaw.split('|').map((s) => s.trim().toLowerCase());
    return validAnswers.contains(input.trim().toLowerCase());
  }

  void _checkAnswer() {
    final prompt = _prompts[_promptIndex];
    final isCorrect = _matches(_controller.text, prompt.correctAnswerRaw);

    setState(() {
      _checked = true;
      _isCorrect = isCorrect;
      isCorrect ? _correctCount++ : _wrongCount++;
      if (!isCorrect) _allCorrectForItem[prompt.item.id] = false;
    });
  }

  Future<void> _next() async {
    final prompt = _prompts[_promptIndex];
    final itemId = prompt.item.id;

    _remainingPromptsForItem[itemId] = _remainingPromptsForItem[itemId]! - 1;

    // This item's last prompt in the whole session just got answered.
    if (_remainingPromptsForItem[itemId] == 0) {
      await _progressService.recordResult(itemId, _allCorrectForItem[itemId]!);
    }

    if (_promptIndex + 1 >= _prompts.length) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    setState(() {
      _promptIndex++;
      _checked = false;
      _isCorrect = null;
      _controller.clear();
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
    if (_prompts.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review')),
        body: const Center(child: Text('Nothing due for review right now.')),
      );
    }

    final prompt = _prompts[_promptIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Correct: $_correctCount', style: const TextStyle(color: Colors.green)),
                Text('${_percentage.toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Wrong: $_wrongCount', style: const TextStyle(color: Colors.red)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: (_promptIndex + 1) / _prompts.length),
            const Spacer(),
            Text(prompt.item.display, style: const TextStyle(fontSize: 56), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(prompt.questionLabel, style: const TextStyle(fontSize: 18, color: AppColors.primary)),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              enabled: !_checked,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onSubmitted: (_) {
                if (!_checked && _controller.text.trim().isNotEmpty) _checkAnswer();
              },
            ),
            const SizedBox(height: 16),
            if (_checked) ...[
              Text(
                _isCorrect! ? 'Correct!' : 'Answer: ${prompt.correctAnswerRaw.split('|').first}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isCorrect! ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _next, child: const Text('Next')),
            ] else
              ElevatedButton(
                onPressed: _controller.text.trim().isEmpty ? null : _checkAnswer,
                child: const Text('Check'),
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}