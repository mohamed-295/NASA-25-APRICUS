import 'package:just_audio/just_audio.dart';
import '../core/constants/audio_constants.dart';
import './storage_service.dart';

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
  bool _musicEnabled = false;  // Default to false until loaded from storage
  bool _sfxEnabled = true;

  Future<void> init() async {
    if (_initialized) return;
    
    // Load saved settings from storage
    _musicEnabled = StorageService.musicEnabled;
    _sfxEnabled = StorageService.sfxEnabled;
    _musicVolume = StorageService.musicVolume;
    _sfxVolume = StorageService.sfxVolume;
    
    // Ensure music player is stopped if music is disabled
    if (!_musicEnabled) {
      await _musicPlayer.stop();
    }
    
    // Create SFX player pool (10 players for multiple simultaneous sounds)
    for (int i = 0; i < 10; i++) {
      _sfxPlayers.add(AudioPlayer());
    }
    
    _initialized = true;
    
    print('AudioService initialized: musicEnabled=$_musicEnabled, sfxEnabled=$_sfxEnabled, musicVol=$_musicVolume, sfxVol=$_sfxVolume');
  }

  // Background Music controls
  Future<void> playBackgroundMusic() async {
    // Wait for initialization if not done yet
    while (!_initialized) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    
    print('playBackgroundMusic called: _musicEnabled=$_musicEnabled');
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
    if (_musicEnabled && _musicPlayer.processingState != ProcessingState.idle) {
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
      stopMusic();  // Stop completely instead of just pausing
      _quizMusicPlayer.stop();
    } else {
      playBackgroundMusic();  // Start fresh when enabling
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
    // Wait for initialization if not done yet
    while (!_initialized) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    
    if (!_sfxEnabled) return;
    
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
    
    // Find available player (not playing or completed)
    AudioPlayer? availablePlayer;
    for (var player in _sfxPlayers) {
      if (!player.playing || player.processingState == ProcessingState.completed || 
          player.processingState == ProcessingState.idle) {
        availablePlayer = player;
        break;
      }
    }
    
    if (availablePlayer != null) {
      try {
        // Stop and reset the player first
        await availablePlayer.stop();
        await availablePlayer.setAsset(assetPath);
        await availablePlayer.setVolume(_sfxVolume);
        await availablePlayer.play();
      } catch (e) {
        print('Error playing SFX $sfxType: $e');
      }
    } else {
      print('No available SFX player - all busy');
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
