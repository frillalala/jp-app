// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/main_menu_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SUPER APP',
      theme: AppTheme.theme,
      home: const MainMenuScreen(),
    );
  }
}