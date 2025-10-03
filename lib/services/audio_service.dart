import 'package:just_audio/just_audio.dart';
import '../core/constants/audio_constants.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _quizMusicPlayer = AudioPlayer();
  final List<AudioPlayer> _sfxPlayers = [];
  
  bool _initialized = false;
  double _musicVolume = AudioConstants.defaultMusicVolume;
  double _sfxVolume = AudioConstants.defaultSfxVolume;
  bool _musicEnabled = true;
  bool _sfxEnabled = true;

  Future<void> init() async {
    if (_initialized) return;
    
    // Create SFX player pool (10 players for multiple simultaneous sounds)
    for (int i = 0; i < 10; i++) {
      _sfxPlayers.add(AudioPlayer());
    }
    
    _initialized = true;
  }

  // Background Music controls
  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;
    
    try {
      await _musicPlayer.setAsset(AudioConstants.backgroundMusic);
      await _musicPlayer.setLoopMode(LoopMode.one);
      await _musicPlayer.setVolume(_musicVolume);
      await _musicPlayer.play();
    } catch (e) {
      print('Error playing background music: $e');
    }
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
    _quizMusicPlayer.setVolume(_musicVolume);
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      pauseMusic();
      _quizMusicPlayer.pause();
    } else {
      resumeMusic();
    }
  }

  // Quiz Music controls
  Future<void> playQuizMusic() async {
    if (!_musicEnabled) return;
    
    try {
      // Fade out background music
      await _musicPlayer.setVolume(_musicVolume * 0.3);
      
      // Play quiz music
      await _quizMusicPlayer.setAsset(AudioConstants.quizMusic);
      await _quizMusicPlayer.setLoopMode(LoopMode.one);
      await _quizMusicPlayer.setVolume(_musicVolume);
      await _quizMusicPlayer.play();
    } catch (e) {
      print('Error playing quiz music: $e');
    }
  }

  Future<void> stopQuizMusic() async {
    try {
      await _quizMusicPlayer.stop();
      // Restore background music volume
      await _musicPlayer.setVolume(_musicVolume);
    } catch (e) {
      print('Error stopping quiz music: $e');
    }
  }

  // SFX controls with specific sound effects
  Future<void> playSfx(String sfxType) async {
    if (!_sfxEnabled) return;
    
    // TODO: Re-encode button.mp3 and success.mp3 - current files are corrupted
    // Temporarily skip button and success sounds to avoid errors
    if (sfxType == 'button' || sfxType == 'success') {
      return; // Skip corrupted sound files
    }
    
    String? assetPath;
    
    switch (sfxType) {
      case 'button':
        assetPath = AudioConstants.buttonClick;
        break;
      case 'success':
        assetPath = AudioConstants.success;
        break;
      case 'quiz_hmm':
        assetPath = AudioConstants.quizHmm;
        break;
      case 'correct':
        assetPath = AudioConstants.correctAnswer;
        break;
      case 'wrong':
        assetPath = AudioConstants.wrongAnswer;
        break;
      default:
        print('Unknown SFX type: $sfxType');
        return;
    }
    
    // Find available player
    AudioPlayer? availablePlayer;
    for (var player in _sfxPlayers) {
      if (!player.playing) {
        availablePlayer = player;
        break;
      }
    }
    
    if (availablePlayer != null) {
      try {
        await availablePlayer.setAsset(assetPath);
        await availablePlayer.setVolume(_sfxVolume);
        await availablePlayer.play();
      } catch (e) {
        print('Error playing SFX $sfxType: $e');
      }
    }
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
    await _quizMusicPlayer.dispose();
    for (var player in _sfxPlayers) {
      await player.dispose();
    }
  }
}
