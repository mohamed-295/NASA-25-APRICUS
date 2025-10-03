import 'package:flutter/material.dart';
import '../../services/audio_service.dart';

class PlayButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double? size;

  const PlayButton({
    super.key,
    required this.onPressed,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? MediaQuery.of(context).size.height * 0.11;
    final iconSize = buttonSize * 0.6;
    final fontSize = buttonSize * 0.35;
    
    return ElevatedButton.icon(
      onPressed: () {
        AudioService().playSfx('button');
        onPressed();
      },
      icon: Icon(Icons.play_arrow, size: iconSize),
      label: Text(
        'PLAY',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: fontSize),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: buttonSize * 0.8,
          vertical: buttonSize * 0.30,
        ),
      ),
    );
  }
}
