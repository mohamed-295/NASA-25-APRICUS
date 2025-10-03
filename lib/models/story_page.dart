class PageContent {
  final String text;
  final String audio;

  PageContent({
    required this.text,
    required this.audio,
  });

  factory PageContent.fromJson(Map<String, dynamic> json) {
    return PageContent(
      text: json['text'] as String? ?? '',
      audio: json['audio'] as String? ?? '',
    );
  }
}

class StoryPage {
  final int pageNumber;
  final String image;
  final Map<String, PageContent> content; // left_bottom, right_bottom, right_up, etc.

  StoryPage({
    required this.pageNumber,
    required this.image,
    required this.content,
  });

  factory StoryPage.fromJson(Map<String, dynamic> json) {
    try {
      final contentJson = json['content'] as Map<String, dynamic>;
      final Map<String, PageContent> parsedContent = {};
      
      contentJson.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          parsedContent[key] = PageContent.fromJson(value);
        }
      });
      
      return StoryPage(
        pageNumber: json['page_number'] as int,
        image: json['image'] as String,
        content: parsedContent,
      );
    } catch (e) {
      print('Error parsing page: $e');
      print('Page JSON: $json');
      rethrow;
    }
  }

  // Helper methods to get text from different positions
  String? get leftBottomText => content['left_bottom']?.text;
  String? get rightBottomText => content['right_bottom']?.text;
  String? get rightUpText => content['right_up']?.text;
  String? get leftUpText => content['left_up']?.text;
  
  // Helper methods to get audio from different positions
  String? get leftBottomAudio => content['left_bottom']?.audio;
  String? get rightBottomAudio => content['right_bottom']?.audio;
  String? get rightUpAudio => content['right_up']?.audio;
  String? get leftUpAudio => content['left_up']?.audio;
  
  // Get all text content as a single string
  String get allText {
    return content.values
        .map((pageContent) => pageContent.text)
        .where((text) => text.isNotEmpty)
        .join(' ');
  }
}
