import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../services/audio_service.dart';

/// Aurora Creator mini-game - Educational game about how auroras form
/// Teaches: Solar wind particles interact with Earth's magnetic field to create auroras
class AuroraCreatorGameScreen extends StatefulWidget {
  const AuroraCreatorGameScreen({super.key});

  @override
  State<AuroraCreatorGameScreen> createState() => _AuroraCreatorGameScreenState();
}

class _AuroraCreatorGameScreenState extends State<AuroraCreatorGameScreen> {
  // Game state
  bool _showingIntro = true; // Show educational intro first
  int _score = 0;
  int _targetScore = 50;
  bool _isPlaying = false;
  bool _gameWon = false;
  Timer? _gameTimer;
  int _timeLeft = 30; // 30 seconds
  
  // Particles (representing solar wind particles)
  final List<Particle> _particles = [];
  final Random _random = Random();
  Timer? _spawnTimer;
  
  // Windy position (player - represents solar wind)
  double _windyX = 0.5;
  double _windyY = 0.5;

  @override
  void initState() {
    super.initState();
    // Don't start game automatically - show intro first
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 30;
      _isPlaying = true;
      _gameWon = false;
      _particles.clear();
    });

    // Start countdown timer
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _endGame();
        }
      });
    });

    // Spawn particles every 500ms
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_isPlaying) {
        _spawnParticle();
      }
    });
  }

  void _spawnParticle() {
    final colors = [Colors.green, Colors.pink, Colors.purple];
    final particle = Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      color: colors[_random.nextInt(colors.length)],
    );
    
    setState(() {
      _particles.add(particle);
      // Keep only last 15 particles
      if (_particles.length > 15) {
        _particles.removeAt(0);
      }
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    setState(() {
      _isPlaying = false;
    });
    
    if (_gameWon) {
      AudioService().playSfx('success');
    }
  }

  void _moveWindy(DragUpdateDetails details, Size size) {
    setState(() {
      _windyX = (details.localPosition.dx / size.width).clamp(0.0, 1.0);
      _windyY = (details.localPosition.dy / size.height).clamp(0.0, 1.0);
      
      // Check for particle collection
      _checkCollisions();
    });
  }

  void _checkCollisions() {
    final collectRadius = 0.08; // 8% of screen
    
    _particles.removeWhere((particle) {
      final dx = particle.x - _windyX;
      final dy = particle.y - _windyY;
      final distance = sqrt(dx * dx + dy * dy);
      
      if (distance < collectRadius) {
        _score += 5;
        AudioService().playSfx('button');
        
        if (_score >= _targetScore) {
          _gameWon = true;
          _endGame();
        }
        return true;
      }
      return false;
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0a0e27),
              Color(0xFF1a1a3e),
              Color(0xFF2d1b4e),
            ],
          ),
        ),
        child: SafeArea(
          child: _showingIntro ? _buildIntroScreen() : _buildGameScreen(),
        ),
      ),
    );
  }

  Widget _buildIntroScreen() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.purple.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Title
            const Text(
              '🌌 Aurora Creator 🌌',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Educational content
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    '🌟 How Auroras Form 🌟',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC084FC),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'The Sun releases charged particles called the solar wind. '
                    'When these particles reach Earth, they interact with our planet\'s '
                    'magnetic field (the invisible shield around Earth).\n\n'
                    'This creates beautiful dancing lights in the sky - the AURORAS!\n\n'
                    'Auroras appear in green, pink, and purple colors!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Game instructions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Column(
                children: [
                  Text(
                    '🎮 Your Mission 🎮',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF60A5FA),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'You are Windy, the solar wind!\n'
                    'Guide the solar wind particles to Earth\'s magnetic field.\n'
                    'Collect 50 particles in 30 seconds to create beautiful auroras!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Start button
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showingIntro = false;
                  _startGame();
                });
                AudioService().playSfx('button');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Start Creating Auroras!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Back button
            TextButton(
              onPressed: () {
                AudioService().playSfx('button');
                Navigator.pop(context);
              },
              child: const Text(
                'Back to Games',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Stack(
      children: [
        // Game area
        if (_isPlaying)
          GestureDetector(
            onPanUpdate: (details) {
              final size = MediaQuery.of(context).size;
              _moveWindy(details, size);
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Earth in center background
                    Center(
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.blue.shade300,
                              Colors.blue.shade600,
                              Colors.blue.shade900,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '🌍',
                            style: TextStyle(fontSize: 60),
                          ),
                        ),
                      ),
                    ),
                    
                    // Particles
                    for (var particle in _particles)
                      Positioned(
                        left: particle.x * constraints.maxWidth - 15,
                        top: particle.y * constraints.maxHeight - 15,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: particle.color.withOpacity(0.7),
                            boxShadow: [
                              BoxShadow(
                                color: particle.color.withOpacity(0.6),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Windy (player - represents solar wind)
                    Positioned(
                      left: _windyX * constraints.maxWidth - 25,
                      top: _windyY * constraints.maxHeight - 25,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.yellow.shade300,
                              Colors.orange.shade400,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.8),
                              blurRadius: 20,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.wb_sunny,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        
        // HUD
        _buildHUD(),
        
        // Game Over / Win overlay
        if (!_isPlaying) _buildGameOverlay(),
      ],
    );
  }

  Widget _buildHUD() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.yellow, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$_score / $_targetScore',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  color: _timeLeft <= 10 ? Colors.red : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_timeLeft s',
                  style: TextStyle(
                    color: _timeLeft <= 10 ? Colors.red : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Back button
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _gameWon 
                  ? [Colors.green.shade700, Colors.green.shade900]
                  : [Colors.blue.shade700, Colors.blue.shade900],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _gameWon ? Colors.green : Colors.blue,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (_gameWon ? Colors.green : Colors.blue).withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Icon(
                _gameWon ? Icons.auto_awesome : Icons.replay,
                size: 70,
                color: Colors.yellow,
              ),
              const SizedBox(height: 16),
              Text(
                _gameWon ? '🎉 Aurora Created!' : '⏰ Time\'s Up!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Educational message
              if (_gameWon)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '✨ You Did It! ✨',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'You guided the solar wind particles to Earth\'s magnetic field, '
                        'creating beautiful auroras! This is exactly how real auroras form '
                        'when the Sun\'s charged particles meet Earth\'s magnetic shield.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                const Text(
                  'Keep trying! The solar wind needs more particles\nto create visible auroras!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              
              const SizedBox(height: 12),
              Text(
                'Particles Collected: $_score',
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      AudioService().playSfx('button');
                      _startGame();
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text('Play Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      AudioService().playSfx('button');
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

// Particle model
class Particle {
  final double x;
  final double y;
  final Color color;

  Particle({
    required this.x,
    required this.y,
    required this.color,
  });
}
