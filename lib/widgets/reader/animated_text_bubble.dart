import 'package:flutter/material.dart';
import 'streaming_text.dart';
import '../../services/voice_service.dart';

class AnimatedTextBubble extends StatefulWidget {
  final String text;
  final String? audioPath;
  final TextAlign textAlign;
  final Alignment scaleAlignment;
  final VoidCallback onCompleted;
  final double? maxWidth;

  const AnimatedTextBubble({
    super.key,
    required this.text,
    this.audioPath,
    required this.textAlign,
    required this.scaleAlignment,
    required this.onCompleted,
    this.maxWidth,
  });

  @override
  State<AnimatedTextBubble> createState() => _AnimatedTextBubbleState();
}

class _AnimatedTextBubbleState extends State<AnimatedTextBubble> {
  @override
  void initState() {
    super.initState();
    // Play voiceover when bubble appears
    if (widget.audioPath != null && widget.audioPath!.isNotEmpty) {
      VoiceService().playVoiceover(widget.audioPath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          alignment: widget.scaleAlignment,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: widget.maxWidth ?? 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        child: StreamingText(
          text: widget.text,
          textAlign: widget.textAlign,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontSize: 16,
            height: 1.3,
          ),
          onCompleted: widget.onCompleted,
        ),
      ),
    );
  }
}
