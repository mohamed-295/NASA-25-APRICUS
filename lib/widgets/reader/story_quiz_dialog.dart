import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/quiz_question.dart';
import '../../services/audio_service.dart';

/// Dialog that displays story quiz questions
class StoryQuizDialog extends StatefulWidget {
  final StoryQuiz quiz;
  final VoidCallback onComplete;

  const StoryQuizDialog({
    super.key,
    required this.quiz,
    required this.onComplete,
  });

  @override
  State<StoryQuizDialog> createState() => _StoryQuizDialogState();
}

class _StoryQuizDialogState extends State<StoryQuizDialog> {
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int? _selectedAnswerIndex;
  bool _showExplanation = false;
  bool _hasPlayedHmm = false;

  @override
  void initState() {
    super.initState();
    // Play quiz music when dialog opens
    AudioService().playQuizMusic();
  }

  @override
  void dispose() {
    // Stop quiz music when dialog closes
    AudioService().stopQuizMusic();
    super.dispose();
  }

  QuizQuestion get _currentQuestion => widget.quiz.questions[_currentQuestionIndex];
  bool get _isLastQuestion => _currentQuestionIndex == widget.quiz.questions.length - 1;

  void _onAnswerSelected(int index) {
    if (_selectedAnswerIndex != null) return; // Already answered

    // Play hmm sound only once when first option is selected
    if (!_hasPlayedHmm) {
      AudioService().playSfx('quiz_hmm');
      _hasPlayedHmm = true;
    }

    setState(() {
      _selectedAnswerIndex = index;
      _showExplanation = true;

      final isCorrect = index == _currentQuestion.correctAnswerIndex;
      if (isCorrect) {
        _correctAnswers++;
        AudioService().playSfx('correct');
      } else {
        AudioService().playSfx('wrong');
      }
    });
  }

  void _onNextQuestion() {
    if (_isLastQuestion) {
      _showResults();
    } else {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _showExplanation = false;
        _hasPlayedHmm = false;
      });
    }
  }

  void _showResults() {
    final score = widget.quiz.calculateScore(_correctAnswers);
    final passed = widget.quiz.isPassed(_correctAnswers);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          passed ? '🎉 Great Job!' : '📚 Keep Learning!',
          style: const TextStyle(fontFamily: 'Mansalva'),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your Score:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '$score%',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: passed ? Colors.green : AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_correctAnswers out of ${widget.quiz.questions.length} correct',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              passed
                  ? 'You\'ve learned a lot about space weather!'
                  : 'Try reading the story again to learn more!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'Mansalva',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close results dialog
              Navigator.of(context).pop(); // Close quiz dialog
              widget.onComplete();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1}/${widget.quiz.questions.length}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.accent,
                  ),
                ),
                Text(
                  'Score: $_correctAnswers',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Question
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Text(
                _currentQuestion.question,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: 'Mansalva',
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),

            // Options
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _currentQuestion.options.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedAnswerIndex == index;
                  final isCorrect = index == _currentQuestion.correctAnswerIndex;
                  final showResult = _showExplanation;

                  Color? backgroundColor;
                  Color? borderColor;

                  if (showResult) {
                    if (isCorrect) {
                      backgroundColor = Colors.green.withOpacity(0.2);
                      borderColor = Colors.green;
                    } else if (isSelected) {
                      backgroundColor = Colors.red.withOpacity(0.2);
                      borderColor = Colors.red;
                    }
                  } else if (isSelected) {
                    backgroundColor = AppColors.accent.withOpacity(0.2);
                    borderColor = AppColors.accent;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => _onAnswerSelected(index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: backgroundColor ?? AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: borderColor ?? AppColors.textSecondary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          _currentQuestion.options[index],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Explanation
            if (_showExplanation) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accent, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppColors.accent,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Did you know?',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _currentQuestion.explanation,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Next/Finish button
            if (_showExplanation)
              ElevatedButton(
                onPressed: _onNextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isLastQuestion ? 'See Results' : 'Next Question',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Mansalva',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
