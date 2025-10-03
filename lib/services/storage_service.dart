import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Music & SFX settings
  static bool get musicEnabled => _prefs?.getBool('music_enabled') ?? true;
  static bool get sfxEnabled => _prefs?.getBool('sfx_enabled') ?? true;
  static double get musicVolume => _prefs?.getDouble('music_volume') ?? 0.7;
  static double get sfxVolume => _prefs?.getDouble('sfx_volume') ?? 0.7;

  static Future<void> setMusicEnabled(bool enabled) async {
    await _prefs?.setBool('music_enabled', enabled);
  }

  static Future<void> setSfxEnabled(bool enabled) async {
    await _prefs?.setBool('sfx_enabled', enabled);
  }

  static Future<void> setMusicVolume(double volume) async {
    await _prefs?.setDouble('music_volume', volume);
  }

  static Future<void> setSfxVolume(double volume) async {
    await _prefs?.setDouble('sfx_volume', volume);
  }

  // Achievements
  static List<String> get unlockedAchievements {
    return _prefs?.getStringList('unlocked_achievements') ?? [];
  }

  static Future<void> unlockAchievement(String achievementId) async {
    final current = unlockedAchievements;
    if (!current.contains(achievementId)) {
      current.add(achievementId);
      await _prefs?.setStringList('unlocked_achievements', current);
    }
  }

  static bool isAchievementUnlocked(String achievementId) {
    return unlockedAchievements.contains(achievementId);
  }

  // Story progress
  static List<int> get completedStories {
    return _prefs?.getStringList('completed_stories')?.map(int.parse).toList() ?? [];
  }

  static Future<void> completeStory(int storyId) async {
    final current = completedStories;
    if (!current.contains(storyId)) {
      current.add(storyId);
      await _prefs?.setStringList(
        'completed_stories',
        current.map((e) => e.toString()).toList(),
      );
    }
  }

  static bool isStoryCompleted(int storyId) {
    return completedStories.contains(storyId);
  }

  // Onboarding hints
  static bool hasSeenTapHintForStory(int storyId) {
    return _prefs?.getBool('tap_hint_seen_story_$storyId') ?? false;
  }

  static Future<void> setSeenTapHintForStory(int storyId) async {
    await _prefs?.setBool('tap_hint_seen_story_$storyId', true);
  }
}
