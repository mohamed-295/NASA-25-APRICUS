import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/story.dart';

class StoryService {
  static Story? _currentStory;

  static Future<Story> loadTestStory() async {
    if (_currentStory != null) return _currentStory!;

    final String response = 
        await rootBundle.loadString('assets/data/test.json');
    final data = json.decode(response) as Map<String, dynamic>;

    _currentStory = Story.fromJson(data);
    return _currentStory!;
  }

  static Story? get currentStory => _currentStory;
}
