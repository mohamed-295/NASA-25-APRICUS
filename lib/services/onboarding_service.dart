import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story.dart';

class OnboardingService {
  static Story? _onboardingStory;
  static const String _keyOnboardingComplete = 'onboarding_completed';

  /// Load the onboarding story from assets
  static Future<Story> loadOnboardingStory() async {
    if (_onboardingStory != null) return _onboardingStory!;

    final String response = 
        await rootBundle.loadString('assets/data/onboarding_story.json');
    final data = json.decode(response) as Map<String, dynamic>;

    // Parse the onboarding story
    _onboardingStory = Story.fromJson(data);
    
    return _onboardingStory!;
  }

  static Story? get onboardingStory => _onboardingStory;
  
  /// Check if user has completed onboarding
  static Future<bool> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyOnboardingComplete) ?? false;
    } catch (e) {
      print('Error checking onboarding status: $e');
      return false;
    }
  }
  
  /// Mark onboarding as completed
  static Future<void> markOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyOnboardingComplete, true);
      print('Onboarding marked as complete');
    } catch (e) {
      print('Error marking onboarding complete: $e');
    }
  }
  
  /// Reset onboarding status (for testing)
  static Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyOnboardingComplete, false);
      print('Onboarding reset');
    } catch (e) {
      print('Error resetting onboarding: $e');
    }
  }
}
