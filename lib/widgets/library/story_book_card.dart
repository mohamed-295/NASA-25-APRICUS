import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/story.dart';
import '../../providers/game_provider.dart';
import '../../services/audio_service.dart';

class StoryBookCard extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;

  const StoryBookCard({
    super.key,
    required this.story,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final isCompleted = gameProvider.isStoryCompleted(story.id);

    return GestureDetector(
      onTap: () {
        AudioService().playSfx('button');
        onTap();
      },
      child: Card(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cover image
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: story.coverImage != null && story.coverImage!.isNotEmpty
                          ? Image.asset(
                              story.coverImage!,
                              fit: BoxFit.scaleDown,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.menu_book,
                                    size: 64,
                                    color: AppColors.primary.withOpacity(0.5),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Icon(
                                Icons.menu_book,
                                size: 64,
                                color: AppColors.primary.withOpacity(0.5),
                              ),
                            ),
                    ),
                  ),
                ),
                
                // Title and Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Column(
                    children: [
                      Text(
                        story.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (story.status != null && story.status!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            story.status!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: story.status!.toLowerCase() == 'released'
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Completed badge
            if (isCompleted)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
