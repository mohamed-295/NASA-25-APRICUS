import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final List<AudioPlayer> _sfxPlayers = [];
  
  bool _initialized = false;
  double _musicVolume = 0.7;
  double _sfxVolume = 0.7;
  bool _musicEnabled = true;
  bool _sfxEnabled = true;

  Future<void> init() async {
    if (_initialized) return;
    
    // Create SFX player pool
    for (int i = 0; i < 5; i++) {
      _sfxPlayers.add(AudioPlayer());
    }
    
    _initialized = true;
  }

  // Music controls
  Future<void> playBackgroundMusic() async {
    // Temporarily disabled until audio assets are ready
    return;
  }

  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeMusic() async {
    if (_musicEnabled) {
      await _musicPlayer.play();
    }
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _musicPlayer.setVolume(_musicVolume);
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      pauseMusic();
    } else {
      resumeMusic();
    }
  }

  // SFX controls
  Future<void> playSfx(String sfxType) async {
    // Temporarily disabled until audio assets are ready
    // Accessing fields to suppress linter warnings
    if (!_sfxEnabled || _sfxVolume == 0) return;
    return;
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
  }

  void setSfxEnabled(bool enabled) {
    _sfxEnabled = enabled;
  }

  // Cleanup
  Future<void> dispose() async {
    await _musicPlayer.dispose();
    for (var player in _sfxPlayers) {
      await player.dispose();
    }
  }
}
