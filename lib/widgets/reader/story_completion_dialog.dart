import 'package:flutter/material.dart';

class StoryCompletionDialog extends StatelessWidget {
  final String storyTitle;
  final VoidCallback onBackToLibrary;
  final VoidCallback onReadAgain;

  const StoryCompletionDialog({
    super.key,
    required this.storyTitle,
    required this.onBackToLibrary,
    required this.onReadAgain,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Story Complete!',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      content: Text(
        'Congratulations! You have finished reading "$storyTitle".',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      actions: [
        TextButton(
          onPressed: onBackToLibrary,
          child: Text(
            'Back to Library',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onReadAgain,
          child: Text(
            'Read Again',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
