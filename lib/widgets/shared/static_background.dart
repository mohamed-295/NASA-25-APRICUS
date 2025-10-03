import 'package:flutter/material.dart';

/// Static background image widget that replaces the animated starfield
class StaticBackground extends StatelessWidget {
  const StaticBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/background.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
