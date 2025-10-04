import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/routes.dart';
import '../services/audio_service.dart';
import '../widgets/shared/static_background.dart';
import '../widgets/shared/play_button.dart';
import '../widgets/hub/sunny_character.dart';
import '../widgets/hub/orbiting_objects.dart';
import '../widgets/hub/play_options_dialog.dart';

class CosmicHubScreen extends StatefulWidget {
  const CosmicHubScreen({super.key});

  @override
  State<CosmicHubScreen> createState() => _CosmicHubScreenState();
}

class _CosmicHubScreenState extends State<CosmicHubScreen> 
    with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    
    // Orbit animation (continuous rotation)
    _orbitController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    // Pulse animation for Sunny
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    // Start or resume background music
    AudioService().playBackgroundMusic();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Resume music when returning to cosmic hub
    AudioService().resumeMusic();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _showChatComingSoon() {
    AudioService().playSfx('button');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.smart_toy, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '🤖 AI Chat coming soon! Ask me about solar flares, auroras, and more!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.accent.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showPlayOptions() {
    AudioService().playSfx('button');
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const PlayOptionsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Static background
          const StaticBackground(),
            
          // Main content
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate responsive sizes based on available height
                final availableHeight = constraints.maxHeight;
                final sunnySize = (availableHeight * 0.4).clamp(120.0, 200.0);
                final titleSize = (availableHeight * 0.08).clamp(24.0, 36.0);
                final subtitleSize = (availableHeight * 0.035).clamp(12.0, 16.0);
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      'Apricus',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: titleSize,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: availableHeight * 0.01),
                    Text(
                      'Space Weather Adventures',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.accent,
                        fontSize: subtitleSize,
                      ),
                    ),
                    
                    SizedBox(height: availableHeight * 0.07),
                    
                    // Sunny with orbiting objects
                    SizedBox(
                      width: sunnySize,
                      height: sunnySize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Orbiting objects
                          OrbitingObjects(orbitAnimation: _orbitController),
                          
                          // Sunny (pulsing)
                          SunnyCharacter(pulseAnimation: _pulseController),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: availableHeight * 0.09),
                    
                    // Play button
                    PlayButton(
                      onPressed: _showPlayOptions,
                    ),
                  ],
                );
              },
            ),
          ),
          
          // Settings button (top right)
          Positioned(
            top: 15,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.settings, size: 32),
              onPressed: () {
                AudioService().playSfx('button');
                Navigator.pushNamed(context, Routes.settings);
              },
            ),
          ),
          
          // Info button (top right, below settings)
          Positioned(
            top: 60,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.info_outline, size: 32),
              onPressed: () {
                AudioService().playSfx('button');
                _showCredits(context);
              },
            ),
          ),
          
          // Chat icon (bottom right)
          Positioned(
            bottom: 40,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                AudioService().playSfx('button');
                _showChatComingSoon();
              },
              backgroundColor: AppColors.accent,
              child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showCredits(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        
        title: Center(
          child: Text('About Apricus', style: Theme.of(context).textTheme.headlineMedium),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Team DRACO', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              Text('Hana Ahmed Saeed', style: Theme.of(context).textTheme.bodyMedium),
              Text('Mohamed Adel Mohamed', style: Theme.of(context).textTheme.bodyMedium),
              Text('Nadine Haytham FathAllah', style: Theme.of(context).textTheme.bodyMedium),
              Text('Ayman Yasser Ahmed', style: Theme.of(context).textTheme.bodyMedium),
              Text('Awwab Khalil Ahmed', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 10),
              Text(
                'Educational space weather game for kids',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'Mansalva',
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AudioService().playSfx('button');
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
