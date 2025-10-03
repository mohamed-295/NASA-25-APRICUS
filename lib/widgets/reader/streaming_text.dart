import 'package:flutter/material.dart';
import 'dart:math' as math;

class StreamingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool autoStart;
  final Duration characterDelay;
  final bool blockPointerWhileStreaming;
  final VoidCallback? onCompleted;

  const StreamingText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.left,
    this.autoStart = true,
    this.characterDelay = const Duration(milliseconds: 100),
    this.blockPointerWhileStreaming = true,
    this.onCompleted,
  });

  @override
  State<StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<StreamingText>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _characterCountAnimation;
  int _displayedCharacters = 0;
  bool _isStreaming = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    // Calculate duration for text streaming
    final baseDuration = widget.text.length * widget.characterDelay.inMilliseconds;
    final totalDuration = baseDuration;
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: totalDuration),
      vsync: this,
    );

    _characterCountAnimation = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _characterCountAnimation.addListener(() {
      final clamped = math.min(_characterCountAnimation.value, widget.text.length);
      if (clamped != _displayedCharacters) {
        setState(() {
          _displayedCharacters = clamped;
        });
      }
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isStreaming = false;
          _isComplete = true;
        });
        widget.onCompleted?.call();
      }
    });

    if (widget.autoStart) {
      _startStreaming();
    }
  }

  @override
  void didUpdateWidget(covariant StreamingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.characterDelay != widget.characterDelay) {
      // Reconfigure animation for new text length or speed
      _animationController.stop();
      final baseDuration = widget.text.length * widget.characterDelay.inMilliseconds;
      final totalDuration = baseDuration;
      
      _animationController.duration = Duration(milliseconds: totalDuration);
      _characterCountAnimation = IntTween(
        begin: 0,
        end: widget.text.length,
      ).animate(CurvedAnimation(parent: _animationController, curve: Curves.linear));
      _displayedCharacters = 0;
      _isStreaming = false;
      _isComplete = false;
      if (widget.autoStart) {
        _startStreaming();
      }
    }
  }

  void _startStreaming() {
    if (_isStreaming || _isComplete) return;
    
    setState(() {
      _isStreaming = true;
    });


    // Start text animation
    _animationController.forward();
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int textLength = widget.text.length;
    final int safeCount = _displayedCharacters.clamp(0, textLength);
    final String displayedText = widget.text.substring(0, safeCount);

    return AbsorbPointer(
      absorbing: widget.blockPointerWhileStreaming && (_isStreaming && !_isComplete),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: widget.style ?? Theme.of(context).textTheme.bodyLarge,
                  children: [
                    TextSpan(text: displayedText),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }
}
