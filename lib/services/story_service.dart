import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/story.dart';

class StoryService {
  static Story? _currentStory;
  static List<Story>? _allStories;

  static Future<List<Story>> loadAllStories() async {
    if (_allStories != null) return _allStories!;

    final String response = 
        await rootBundle.loadString('assets/data/stories.json');
    final data = json.decode(response) as Map<String, dynamic>;

    _allStories = (data['story'] as List)
        .map((storyJson) => Story.fromJson(storyJson))
        .toList();
    
    return _allStories!;
  }

  static Future<Story> loadStoryById(int storyId) async {
    final stories = await loadAllStories();
    return stories.firstWhere((story) => story.id == storyId);
  }

  static Future<Story> loadTestStory() async {
    // For backward compatibility, load the first story
    final stories = await loadAllStories();
    _currentStory = stories.first;
    return _currentStory!;
  }

  static Story? get currentStory => _currentStory;
  
  static void setCurrentStory(Story story) {
    _currentStory = story;
  }
}
