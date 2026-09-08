// lib/widgets/centered_page.dart
import 'package:flutter/material.dart';

class CenteredPage extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const CenteredPage({super.key, required this.child, this.maxWidth = 600});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}