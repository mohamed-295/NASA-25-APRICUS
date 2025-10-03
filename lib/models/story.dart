import 'story_page.dart';

class Story {
  final int id;
  final String title;
  final List<StoryPage> pages;

  Story({
    required this.id,
    required this.title,
    required this.pages,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    try {
      final storyData = json['story'] as Map<String, dynamic>;
      final id = storyData['id'] as int;
      final title = storyData['title'] as String;
      
      final pagesJson = storyData['pages'] as List;
      final pages = pagesJson
          .map((page) => StoryPage.fromJson(page))
          .toList();
      
      return Story(
        id: id,
        title: title,
        pages: pages,
      );
    } catch (e, stackTrace) {
      print('Error parsing story: $e');
      print('Stack trace: $stackTrace');
      print('Story title: ${json['story']?['title']}');
      rethrow;
    }
  }
}
