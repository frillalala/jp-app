// lib/screens/n5_menu_screen.dart
import 'package:flutter/material.dart';
import 'flashcard_screen.dart';
import '../services/vocab_loader.dart';

class N5MenuScreen extends StatelessWidget {
  const N5MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Vocab', 'enabled': true},
      {'label': 'Grammar', 'enabled': false},
      {'label': 'Kanji', 'enabled': false},
      {'label': 'Reading', 'enabled': false},
      {'label': 'Listening', 'enabled': false},
      {'label': 'Mock Test', 'enabled': false},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('N5')),
      body: ListView(
        children: items.map((item) {
          final label = item['label'] as String;
          final isEnabled = item['enabled'] as bool;
          return ListTile(
            title: Text(label),
            enabled: isEnabled,
            trailing: isEnabled ? const Icon(Icons.arrow_forward_ios) : null,
            onTap: isEnabled
                ? () async {
                    final cards = await loadVocab();
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FlashcardScreen(cards: cards),
                        ),
                      );
                    }
                  }
                : null,
          );
        }).toList(),
      ),
    );
  }
}