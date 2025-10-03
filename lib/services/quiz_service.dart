import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quiz_question.dart';
import '../models/story.dart';

/// Service for loading and managing story quizzes from stories.json
class QuizService {
  static final QuizService _instance = QuizService._internal();
  factory QuizService() => _instance;
  QuizService._internal();

  Map<String, StoryQuiz>? _quizzes;

  /// Load all quizzes from stories.json
  Future<void> loadQuizzes() async {
    if (_quizzes != null) return; // Already loaded

    try {
      final String jsonString = await rootBundle.loadString('assets/data/stories.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> stories = jsonData['story'] as List; // Changed from 'stories' to 'story'

      _quizzes = {};
      for (var storyData in stories) {
        final story = Story.fromJson(storyData as Map<String, dynamic>);
        if (story.quiz != null) {
          _quizzes!['story_${story.id}'] = story.quiz!;
        }
      }
    } catch (e) {
      print('Error loading quizzes from stories: $e');
      _quizzes = {};
    }
  }

  /// Get quiz for a specific story
  StoryQuiz? getQuizForStory(String storyId) {
    return _quizzes?[storyId];
  }

  /// Check if a story has a quiz
  bool hasQuiz(String storyId) {
    return _quizzes?.containsKey(storyId) ?? false;
  }

  /// Get all available quizzes
  List<StoryQuiz> getAllQuizzes() {
    return _quizzes?.values.toList() ?? [];
  }
}
