// lib/screens/main_menu_screen.dart
import 'package:flutter/material.dart';
import '../config/levels.dart';
import 'level_menu_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SUPER APP')),
      body: ListView(
        children: jlptLevels.map((level) {
          final isEnabled = level == 'N5'; // expand this as you add more levels
          return ListTile(
            title: Text(level),
            enabled: isEnabled,
            trailing: isEnabled ? const Icon(Icons.arrow_forward_ios) : null,
            onTap: isEnabled
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LevelMenuScreen(level: level)),
                    )
                : null,
          );
        }).toList(),
      ),
    );
  }
}