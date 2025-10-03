import 'package:flutter/material.dart';
import '../models/story.dart';
import '../services/storage_service.dart';

class GameProvider extends ChangeNotifier {
  // Current story being read
  Story? _currentStory;
  int _currentPageIndex = 0;

  // Settings
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  double _musicVolume = 0.7;
  double _sfxVolume = 0.7;

  // Getters
  Story? get currentStory => _currentStory;
  int get currentPageIndex => _currentPageIndex;
  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  // Initialize from storage
  Future<void> loadSettings() async {
    _musicEnabled = StorageService.musicEnabled;
    _sfxEnabled = StorageService.sfxEnabled;
    _musicVolume = StorageService.musicVolume;
    _sfxVolume = StorageService.sfxVolume;
    notifyListeners();
  }

  // Story navigation
  void setCurrentStory(Story story) {
    _currentStory = story;
    _currentPageIndex = 0;
    notifyListeners();
  }

  void nextPage() {
    if (_currentStory != null && 
        _currentPageIndex < _currentStory!.pages.length - 1) {
      _currentPageIndex++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPageIndex > 0) {
      _currentPageIndex--;
      notifyListeners();
    }
  }

  void goToPage(int index) {
    if (_currentStory != null && 
        index >= 0 && 
        index < _currentStory!.pages.length) {
      _currentPageIndex = index;
      notifyListeners();
    }
  }

  bool get isLastPage {
    if (_currentStory == null) return false;
    return _currentPageIndex >= _currentStory!.pages.length - 1;
  }

  // Settings
  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    await StorageService.setMusicEnabled(enabled);
    notifyListeners();
  }

  Future<void> setSfxEnabled(bool enabled) async {
    _sfxEnabled = enabled;
    await StorageService.setSfxEnabled(enabled);
    notifyListeners();
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume;
    await StorageService.setMusicVolume(volume);
    notifyListeners();
  }

  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume;
    await StorageService.setSfxVolume(volume);
    notifyListeners();
  }

  // Achievements & Progress
  Future<void> completeStory(int storyId) async {
    await StorageService.completeStory(storyId);
    notifyListeners();
  }

  Future<void> unlockAchievement(String achievementId) async {
    await StorageService.unlockAchievement(achievementId);
    notifyListeners();
  }

  bool isStoryCompleted(int storyId) {
    return StorageService.isStoryCompleted(storyId);
  }

  bool isAchievementUnlocked(String achievementId) {
    return StorageService.isAchievementUnlocked(achievementId);
  }

  int get completedStoriesCount {
    return StorageService.completedStories.length;
  }
}
