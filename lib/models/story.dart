import 'story_page.dart';
import 'quiz_question.dart';

class Story {
  final int id;
  final String title;
  final String? coverImage;
  final String? status;
  final String? minigame; // Route to mini-game (e.g., 'aurora_creator')
  final List<StoryPage> pages;
  final StoryQuiz? quiz;

  Story({
    required this.id,
    required this.title,
    this.coverImage,
    this.status,
    this.minigame,
    required this.pages,
    this.quiz,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    try {
      // Check if this is a nested story (old format), onboarding, or direct story object
      final storyData = json.containsKey('story') 
          ? json['story'] as Map<String, dynamic>
          : json.containsKey('on-boarding')
              ? json['on-boarding'] as Map<String, dynamic>
              : json;
          
      final id = storyData['id'] as int;
      final title = storyData['title'] as String;
      final coverImage = storyData['cover_image'] as String?;
      final status = storyData['status'] as String?;
      
      final pagesJson = storyData['pages'] as List;
      final pages = pagesJson
          .map((page) => StoryPage.fromJson(page))
          .toList();
      
      // Load quiz if available (check both 'quiz' and 'final_quiz' keys)
      StoryQuiz? quiz;
      if (storyData.containsKey('final_quiz')) {
        quiz = StoryQuiz.fromJson('story_$id', storyData['final_quiz'] as Map<String, dynamic>);
      } else if (storyData.containsKey('quiz')) {
        quiz = StoryQuiz.fromJson('story_$id', storyData['quiz'] as Map<String, dynamic>);
      }
      
      return Story(
        id: id,
        title: title,
        coverImage: coverImage,
        status: status,
        minigame: storyData['minigame'] as String?,
        pages: pages,
        quiz: quiz,
      );
    } catch (e, stackTrace) {
      print('Error parsing story: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow;
    }
  }
}
