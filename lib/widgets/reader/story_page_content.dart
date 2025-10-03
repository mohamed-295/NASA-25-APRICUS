import 'package:flutter/material.dart';
import '../../models/story_page.dart';
import 'animated_text_bubble.dart';

class StoryPageContent extends StatelessWidget {
  final StoryPage page;
  final int currentTextIndex;
  final bool leftDone;
  final bool rightDone;
  final bool showTapHint;
  final VoidCallback onLeftDone;
  final VoidCallback onRightDone;

  const StoryPageContent({
    super.key,
    required this.page,
    required this.currentTextIndex,
    required this.leftDone,
    required this.rightDone,
    required this.showTapHint,
    required this.onLeftDone,
    required this.onRightDone,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageWidth = constraints.maxWidth;
        final imageHeight = constraints.maxHeight;
        
        return Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                page.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: imageWidth,
                    height: imageHeight,
                    color: Colors.grey[800],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Image not found',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            page.image,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Text overlays
            ..._buildTextOverlays(context),
          ],
        );
      },
    );
  }

  List<Widget> _buildTextOverlays(BuildContext context) {
    final overlays = <Widget>[];

    // Show left text if tapped at least once
    if (currentTextIndex >= 1 && page.leftBottomText != null && page.leftBottomText!.isNotEmpty) {
      overlays.add(
        Positioned(
          left: 60,
          bottom: 30,
          child: AnimatedTextBubble(
            text: page.leftBottomText!,
            audioPath: page.leftBottomAudio,
            textAlign: TextAlign.left,
            scaleAlignment: Alignment.bottomLeft,
            onCompleted: onLeftDone,
          ),
        ),
      );
    }

    // Show right text if tapped twice or more
    if (currentTextIndex >= 2) {
      if (page.rightBottomText != null && page.rightBottomText!.isNotEmpty) {
        overlays.add(
          Positioned(
            right: 70,
            bottom: 30,
            child: AnimatedTextBubble(
              text: page.rightBottomText!,
              audioPath: page.rightBottomAudio,
              textAlign: TextAlign.right,
              scaleAlignment: Alignment.bottomRight,
              onCompleted: onRightDone,
            ),
          ),
        );
      } else if (page.rightUpText != null && page.rightUpText!.isNotEmpty) {
        overlays.add(
          Positioned(
            right: 50,
            top: 30,
            child: AnimatedTextBubble(
              text: page.rightUpText!,
              audioPath: page.rightUpAudio,
              textAlign: TextAlign.right,
              scaleAlignment: Alignment.topRight,
              onCompleted: onRightDone,
            ),
          ),
        );
      } else if (page.leftUpText != null && page.leftUpText!.isNotEmpty) {
        overlays.add(
          Positioned(
            left: 50,
            top: 30,
            child: AnimatedTextBubble(
              text: page.leftUpText!,
              audioPath: page.leftUpAudio,
              textAlign: TextAlign.left,
              scaleAlignment: Alignment.topLeft,
              onCompleted: onRightDone,
            ),
          ),
        );
      }
    }

    // Add tap indicator
    if (showTapHint && currentTextIndex < 2) {
      overlays.add(
        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.touch_app,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Tap to continue',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return overlays;
  }
}
