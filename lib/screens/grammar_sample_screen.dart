// lib/screens/grammar_sample_screen.dart
import 'package:flutter/material.dart';
import '../models/grammar_item.dart';
import 'grammar_exercise_screen.dart';

class GrammarSampleScreen extends StatelessWidget {
  final GrammarItem sample;
  final List<GrammarItem> exercises;
  final String categoryTitle;

  const GrammarSampleScreen({
    super.key,
    required this.sample,
    required this.exercises,
    required this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sample.sentence, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(sample.hiragana, style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(sample.meaning, style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
            const SizedBox(height: 16),
            if (sample.description.isNotEmpty)
              Text(sample.description, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GrammarExerciseScreen(exercises: exercises),
                    ),
                  );
                },
                child: const Text('Next: Practice'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}