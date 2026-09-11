// lib/screens/grammar_category_flow_screen.dart
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/grammar_item.dart';
import '../services/progress_service.dart';
import '../widgets/centered_page.dart';
import '../theme/app_theme.dart';

class _WordTile {
  final String id;
  final String text;
  _WordTile(this.id, this.text);
}

class GrammarCategoryFlowScreen extends StatefulWidget {
  final String category;
  final List<String> grammarOrder; // ordered grammar names in this category
  final List<GrammarItem> allItems; // all items (sample+exercise) for this category
  final int startIndex; // which grammar in grammarOrder to start from

  const GrammarCategoryFlowScreen({
    super.key,
    required this.category,
    required this.grammarOrder,
    required this.allItems,
    this.startIndex = 0,
  });

  @override
  State<GrammarCategoryFlowScreen> createState() => _GrammarCategoryFlowScreenState();
}

class _GrammarCategoryFlowScreenState extends State<GrammarCategoryFlowScreen> {
  final _progressService = GrammarProgressService();

  late int _groupIndex;
  bool _showingSample = true;

  List<GrammarItem> _currentExercises = [];
  int _exIndex = 0;
  List<_WordTile> _bank = [];
  List<_WordTile?> _slots = [];
  bool _checked = false;
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _groupIndex = widget.startIndex;
  }

  String get _currentGrammar => widget.grammarOrder[_groupIndex];

  GrammarItem get _currentSample => widget.allItems.firstWhere(
        (i) => i.grammar == _currentGrammar && i.isSample,
        orElse: () => widget.allItems.firstWhere((i) => i.grammar == _currentGrammar),
      );

  void _startExercises() {
    final exercises = widget.allItems
        .where((i) => i.grammar == _currentGrammar && i.isExercise)
        .toList()
      ..shuffle();
    setState(() {
      _currentExercises = exercises;
      _exIndex = 0;
      _showingSample = false;
    });
    _setupCurrentExercise();
  }

  void _setupCurrentExercise() {
    if (_currentExercises.isEmpty) {
      _advanceGroup();
      return;
    }
    final current = _currentExercises[_exIndex];
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
    final current = _currentExercises[_exIndex];
    if (_slots.any((s) => s == null)) return;

    final answer = _slots.map((s) => s!.text).toList();
    final isCorrect = const ListEquality().equals(answer, current.words);

    setState(() {
      _checked = true;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      await _progressService.markMastered(current.gid);
    } else {
      await _progressService.unmarkMastered(current.gid);
    }
  }

  void _nextExercise() {
    _exIndex++;
    if (_exIndex < _currentExercises.length) {
      _setupCurrentExercise();
    } else {
      _advanceGroup();
    }
  }

  void _advanceGroup() {
    if (_groupIndex + 1 < widget.grammarOrder.length) {
      setState(() {
        _groupIndex++;
        _showingSample = true;
      });
    } else {
      // Finished the whole category — pop back to the category menu
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _showingSample ? _buildSampleView() : _buildExerciseView();
  }

  Widget _buildSampleView() {
  final sample = _currentSample;
  return Scaffold(
    appBar: AppBar(title: Text(_currentGrammar)),
    body: CenteredPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Text(sample.sentence, style: const TextStyle(fontSize: 26), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(sample.hiragana, style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(sample.meaning, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            if (sample.description.isNotEmpty)
              MarkdownBody(
                data: sample.description,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                  strong: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  em: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54),
                  h1: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  h1Padding: const EdgeInsets.only(top: 24, bottom: 8),
                  h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  h2Padding: const EdgeInsets.only(top: 16, bottom: 6),
                  h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  h3Padding: const EdgeInsets.only(top: 16, bottom: 0),
                  listBullet: const TextStyle(fontSize: 16),
                  blockquote: const TextStyle(fontSize: 15, color: Colors.grey, fontStyle: FontStyle.italic),
                  blockquoteDecoration: BoxDecoration(
                    border: Border(left: BorderSide(color: Colors.grey.shade400, width: 3)),
                  ),
                  code: TextStyle(
                    backgroundColor: Colors.grey.shade200,
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _startExercises,
          child: const Text('Next: Practice'),
        ),
      ),
    ),
  );
}

  Widget _buildExerciseView() {
    if (_currentExercises.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final current = _currentExercises[_exIndex];

    return Scaffold(
      appBar: AppBar(title: Text('$_currentGrammar — ${_exIndex + 1}/${_currentExercises.length}')),
      body: CenteredPage(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(current.meaning, style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < _slots.length; i++)
                    DragTarget<_WordTile>(
                      onAcceptWithDetails: (details) => _placeInSlot(details.data, i),
                      builder: (context, candidateData, rejectedData) {
                        final tile = _slots[i];
                        return ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 64, minHeight: 48),
                          child: IntrinsicWidth(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              height: 48,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                color: candidateData.isNotEmpty ? Colors.blue.shade50 : Colors.white,
                              ),
                              child: Center(
                                child: tile == null
                                    ? null
                                    : Draggable<_WordTile>(
                                        data: tile,
                                        feedback: Material(child: _wordChip(tile.text)),
                                        childWhenDragging: const SizedBox.shrink(),
                                        child: Text(tile.text, style: const TextStyle(fontSize: 18)),
                                      ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 32),
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