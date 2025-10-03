import 'package:just_audio/just_audio.dart';

/// Service for playing voiceover audio for story narration
class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final AudioPlayer _voicePlayer = AudioPlayer();
  bool _isEnabled = true;

  /// Play voiceover from asset path
  Future<void> playVoiceover(String audioPath) async {
    if (!_isEnabled || audioPath.isEmpty) return;

    try {
      // Stop any currently playing voiceover
      await _voicePlayer.stop();
      
      // Load and play new voiceover
      await _voicePlayer.setAsset(audioPath);
      await _voicePlayer.setVolume(1.0);
      await _voicePlayer.play();
    } catch (e) {
      print('Error playing voiceover: $e');
      // Silently fail - voiceover is optional
    }
  }

  /// Stop currently playing voiceover
  Future<void> stopVoiceover() async {
    try {
      await _voicePlayer.stop();
    } catch (e) {
      print('Error stopping voiceover: $e');
    }
  }

  /// Pause voiceover
  Future<void> pauseVoiceover() async {
    try {
      await _voicePlayer.pause();
    } catch (e) {
      print('Error pausing voiceover: $e');
    }
  }

  /// Resume voiceover
  Future<void> resumeVoiceover() async {
    try {
      await _voicePlayer.play();
    } catch (e) {
      print('Error resuming voiceover: $e');
    }
  }

  /// Set voiceover enabled/disabled
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled) {
      stopVoiceover();
    }
  }

  /// Check if voiceover is enabled
  bool get isEnabled => _isEnabled;

  /// Cleanup
  Future<void> dispose() async {
    await _voicePlayer.dispose();
  }
}
