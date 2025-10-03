import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../widgets/shared/starfield_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          const StarfieldBackground(),
          
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
                        'Settings',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Settings content
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.9,
                          minHeight: MediaQuery.of(context).size.height - 200,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Consumer<GameProvider>(
                          builder: (context, gameProvider, _) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              // Music settings
                              _buildSettingSection(
                                context,
                                icon: Icons.music_note,
                                title: 'Background Music',
                                enabled: gameProvider.musicEnabled,
                                volume: gameProvider.musicVolume,
                                onToggle: (value) async {
                                  await gameProvider.setMusicEnabled(value);
                                  AudioService().setMusicEnabled(value);
                                },
                                onVolumeChange: (value) {
                                  gameProvider.setMusicVolume(value);
                                  AudioService().setMusicVolume(value);
                                },
                              ),
                              
                              const SizedBox(height: 32),
                              const Divider(color: AppColors.primary),
                              const SizedBox(height: 32),
                              
                              // SFX settings
                              _buildSettingSection(
                                context,
                                icon: Icons.volume_up,
                                title: 'Sound Effects',
                                enabled: gameProvider.sfxEnabled,
                                volume: gameProvider.sfxVolume,
                                onToggle: (value) async {
                                  await gameProvider.setSfxEnabled(value);
                                  AudioService().setSfxEnabled(value);
                                },
                                onVolumeChange: (value) {
                                  gameProvider.setSfxVolume(value);
                                  AudioService().setSfxVolume(value);
                                },
                              ),
                              
                              const SizedBox(height: 40),
                              
                              // About section
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.background.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Apricus v1.0.0',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Team DRACO',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        ),
                      ),
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

  Widget _buildSettingSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool enabled,
    required double volume,
    required ValueChanged<bool> onToggle,
    required ValueChanged<double> onVolumeChange,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle row
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Switch(
              value: enabled,
              onChanged: (value) {
                AudioService().playSfx('button');
                onToggle(value);
              },
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
        
        // Volume slider
        if (enabled) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.volume_down, size: 20),
              Expanded(
                child: Slider(
                  value: volume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  label: '${(volume * 100).round()}%',
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.primary.withOpacity(0.3),
                  onChanged: onVolumeChange,
                ),
              ),
              const Icon(Icons.volume_up, size: 20),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  '${(volume * 100).round()}%',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
