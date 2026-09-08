// lib/screens/grammar_exercise_screen.dart
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../models/grammar_item.dart';
import '../services/progress_service.dart';

class _WordTile {
  final String id;
  final String text;
  _WordTile(this.id, this.text);
}

class GrammarExerciseScreen extends StatefulWidget {
  final List<GrammarItem> exercises;
  const GrammarExerciseScreen({super.key, required this.exercises});

  @override
  State<GrammarExerciseScreen> createState() => _GrammarExerciseScreenState();
}

class _GrammarExerciseScreenState extends State<GrammarExerciseScreen> {
  final _progressService = GrammarProgressService();
  List<GrammarItem> _deck = [];
  int _index = 0;
  bool _loading = true;
  int _correctCount = 0;
  int _wrongCount = 0;

  List<_WordTile> _bank = [];
  List<_WordTile?> _slots = [];
  bool _checked = false;
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _buildDeck();
  }

  Future<void> _buildDeck() async {
    final priority = <GrammarItem>[];
    final mastered = <GrammarItem>[];
    for (final ex in widget.exercises) {
      final isMastered = await _progressService.isMastered(ex.gid);
      (isMastered ? mastered : priority).add(ex);
    }
    priority.shuffle();
    mastered.shuffle();
    setState(() {
      _deck = [...priority, ...mastered];
      _index = 0;
      _loading = false;
    });
    _setupCurrentExercise();
  }

  void _setupCurrentExercise() {
    final current = _deck[_index];
    final tiles = <_WordTile>[
      for (var i = 0; i < current.words.length; i++) _WordTile('w$i', current.words[i])
    ]..shuffle();
    setState(() {
      _bank = tiles;
      _slots = List<_WordTile?>.filled(current.words.length, null);
      _checked = false;
      _isCorrect = null;
    });
  }

  void _placeInSlot(_WordTile tile, int slotIndex) {
    setState(() {
      _bank.removeWhere((t) => t.id == tile.id);
      for (var i = 0; i < _slots.length; i++) {
        if (_slots[i]?.id == tile.id) _slots[i] = null;
      }
      final existing = _slots[slotIndex];
      if (existing != null) _bank.add(existing);
      _slots[slotIndex] = tile;
    });
  }

  void _returnToBank(_WordTile tile) {
    setState(() {
      for (var i = 0; i < _slots.length; i++) {
        if (_slots[i]?.id == tile.id) _slots[i] = null;
      }
      if (!_bank.any((t) => t.id == tile.id)) _bank.add(tile);
    });
  }

  Future<void> _checkAnswer() async {
    final current = _deck[_index];
    if (_slots.any((s) => s == null)) return;

    final answer = _slots.map((s) => s!.text).toList();
    final isCorrect = const ListEquality().equals(answer, current.words);

    setState(() {
      _checked = true;
      _isCorrect = isCorrect;
      isCorrect ? _correctCount++ : _wrongCount++;
    });

    if (isCorrect) {
      await _progressService.markMastered(current.gid);
    } else {
      await _progressService.unmarkMastered(current.gid);
    }
  }

  void _nextExercise() {
    setState(() {
      _index++;
      if (_index >= _deck.length) _index = 0;
    });
    _setupCurrentExercise();
  }

  double get _percentage {
    final total = _correctCount + _wrongCount;
    return total == 0 ? 0 : (_correctCount / total) * 100;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _deck.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final current = _deck[_index];

    return Scaffold(
      appBar: AppBar(title: const Text('Grammar Exercise')),
      body: Padding(
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
            const SizedBox(height: 8),
            Text(current.meaning, style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
            const SizedBox(height: 24),

            // Answer slots (drop targets)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < _slots.length; i++)
                  DragTarget<_WordTile>(
                    onAcceptWithDetails: (details) => _placeInSlot(details.data, i),
                    builder: (context, candidateData, rejectedData) {
                      final tile = _slots[i];
                      return Container(
                        width: 64,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: candidateData.isNotEmpty ? Colors.blue.shade50 : Colors.white,
                        ),
                        child: tile == null
                            ? null
                            : Draggable<_WordTile>(
                                data: tile,
                                feedback: Material(child: _wordChip(tile.text)),
                                childWhenDragging: const SizedBox.shrink(),
                                child: Text(tile.text, style: const TextStyle(fontSize: 18)),
                              ),
                      );
                    },
                  ),
              ],
            ),

            const SizedBox(height: 32),

            // Word bank (also a drop target, so tiles can be dragged back)
            DragTarget<_WordTile>(
              onAcceptWithDetails: (details) => _returnToBank(details.data),
              builder: (context, candidateData, rejectedData) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(minHeight: 64),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _bank.map((tile) {
                      return Draggable<_WordTile>(
                        data: tile,
                        feedback: Material(child: _wordChip(tile.text)),
                        childWhenDragging: Opacity(opacity: 0.3, child: _wordChip(tile.text)),
                        child: _wordChip(tile.text),
                      );
                    }).toList(),
                  ),
                );
              },
            ),

            const Spacer(),

            if (_checked) ...[
              Text(current.hiragana, style: const TextStyle(fontSize: 18)),
              Text(current.meaning, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              Text(
                _isCorrect! ? 'Correct!' : 'Not quite — check the order above.',
                style: TextStyle(
                  color: _isCorrect! ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _nextExercise, child: const Text('Next')),
            ] else
              ElevatedButton(
                onPressed: _slots.any((s) => s == null) ? null : _checkAnswer,
                child: const Text('Check'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _wordChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 18)),
    );
  }
}