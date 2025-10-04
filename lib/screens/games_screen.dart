import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/routes.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../widgets/shared/static_background.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          const StaticBackground(),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Back button
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 32),
                        onPressed: () {
                          AudioService().playSfx('button');
                          Navigator.pop(context);
                        },
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Title
                      Text(
                        'Mini Games',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 32,
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Games icon
                      Icon(
                        Icons.videogame_asset,
                        size: 32,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                ),
                
                // Games grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Consumer<GameProvider>(
                      builder: (context, gameProvider, _) {
                        return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: _games.length,
                          itemBuilder: (context, index) {
                            final game = _games[index];
                            final isUnlocked = gameProvider.isStoryCompleted(game['requiredStory']);
                            
                            return _GameCard(
                              title: game['title'],
                              description: game['description'],
                              icon: game['icon'],
                              color: game['color'],
                              requiredStory: game['requiredStory'],
                              isUnlocked: isUnlocked,
                              onTap: () => _handleGameTap(context, game, isUnlocked),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleGameTap(BuildContext context, Map<String, dynamic> game, bool isUnlocked) {
    AudioService().playSfx('button');
    
    if (!isUnlocked) {
      // Show locked message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.lock, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '🔒 Complete "${game['requiredStoryTitle']}" to unlock this game!',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.textSecondary,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    
    // Navigate to the game
    Navigator.pushNamed(context, game['route']);
  }

  // List of available mini-games
  static final List<Map<String, dynamic>> _games = [
    {
      'title': 'Aurora Creator',
      'description': 'Learn how auroras form! Guide solar wind particles to Earth\'s magnetic field to create beautiful lights.',
      'icon': Icons.auto_awesome,
      'color': Color(0xFF10B981), // Green
      'requiredStory': 1,
      'requiredStoryTitle': 'Sunny and Windy',
      'route': Routes.auroraCreator,
    },
    // Add more games here in the future
    // {
    //   'title': 'Solar Flare',
    //   'description': 'Help Sunny manage solar flares!',
    //   'icon': Icons.whatshot,
    //   'color': Color(0xFFEF4444),
    //   'requiredStory': 2,
    //   'requiredStoryTitle': "Sunny's Big Sneeze",
    //   'route': Routes.solarFlare,
    // },
  ];
}

class _GameCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int requiredStory;
  final bool isUnlocked;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.requiredStory,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isUnlocked ? 8 : 2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isUnlocked
                  ? [
                      color.withOpacity(0.3),
                      color.withOpacity(0.1),
                    ]
                  : [
                      AppColors.textSecondary.withOpacity(0.2),
                      AppColors.textSecondary.withOpacity(0.1),
                    ],
            ),
          ),
          child: Stack(
            children: [
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? color.withOpacity(0.2)
                            : AppColors.textSecondary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isUnlocked ? color : AppColors.textSecondary,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 48,
                        color: isUnlocked ? color : AppColors.textSecondary,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Title
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 18,
                        color: isUnlocked ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Description
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: isUnlocked 
                            ? AppColors.textSecondary 
                            : AppColors.textSecondary.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const Spacer(),
                    
                    // Status indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? AppColors.success.withOpacity(0.2)
                            : AppColors.textSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isUnlocked ? AppColors.success : AppColors.textSecondary,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isUnlocked ? Icons.check_circle : Icons.lock,
                            size: 14,
                            color: isUnlocked ? AppColors.success : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isUnlocked ? 'Unlocked' : 'Locked',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: isUnlocked ? AppColors.success : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Lock overlay (only show if locked)
              if (!isUnlocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.lock,
                        size: 64,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
