/// Represents a single quiz question
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['text'] as String? ?? json['question'] as String? ?? '',
      options: List<String>.from(json['options'] as List? ?? []),
      correctAnswerIndex: json['correct_answer'] as int? ?? json['correctIndex'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctIndex': correctAnswerIndex,
      'explanation': explanation,
    };
  }
}

/// Represents a quiz for a specific story
class StoryQuiz {
  final String storyId;
  final List<QuizQuestion> questions;
  final int passingScore; // Percentage (e.g., 80 = 80%)

  const StoryQuiz({
    required this.storyId,
    required this.questions,
    this.passingScore = 80,
  });

  factory StoryQuiz.fromJson(String storyId, Map<String, dynamic> json) {
    return StoryQuiz(
      storyId: storyId,
      questions: (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      passingScore: json['passingScore'] as int? ?? 80,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questions': questions.map((q) => q.toJson()).toList(),
      'passingScore': passingScore,
    };
  }

  /// Calculate score percentage from correct answers
  int calculateScore(int correctAnswers) {
    if (questions.isEmpty) return 0;
    return ((correctAnswers / questions.length) * 100).round();
  }

  /// Check if user passed the quiz
  bool isPassed(int correctAnswers) {
    return calculateScore(correctAnswers) >= passingScore;
  }
}
