// lib/screens/main_menu_screen.dart
import 'package:flutter/material.dart';
import 'n5_menu_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  static const levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JP Flashcards')),
      body: ListView(
        children: levels.map((level) {
          final isEnabled = level == 'N5';
          return ListTile(
            title: Text(level),
            enabled: isEnabled,
            trailing: isEnabled ? const Icon(Icons.arrow_forward_ios) : null,
            onTap: isEnabled
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const N5MenuScreen()),
                    )
                : null,
          );
        }).toList(),
      ),
    );
  }
}