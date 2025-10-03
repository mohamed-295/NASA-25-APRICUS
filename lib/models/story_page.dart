class StoryPage {
  final int pageNumber;
  final String image;
  final Map<String, String> content; // left_bottom, right_bottom, right_up, etc.

  StoryPage({
    required this.pageNumber,
    required this.image,
    required this.content,
  });

  factory StoryPage.fromJson(Map<String, dynamic> json) {
    try {
      return StoryPage(
        pageNumber: json['page_number'] as int,
        image: json['image'] as String,
        content: Map<String, String>.from(json['content'] as Map<String, dynamic>),
      );
    } catch (e) {
      print('Error parsing page: $e');
      print('Page JSON: $json');
      rethrow;
    }
  }

  // Helper methods to get text from different positions
  String? get leftBottomText => content['left_bottom'];
  String? get rightBottomText => content['right_bottom'];
  String? get rightUpText => content['right_up'];
  String? get leftUpText => content['left_up'];
  
  // Get all text content as a single string
  String get allText {
    return content.values.where((text) => text.isNotEmpty).join(' ');
  }
}
