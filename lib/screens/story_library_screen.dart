import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/story.dart';
import '../providers/game_provider.dart';
import '../services/story_service.dart';
import '../services/audio_service.dart';
import '../widgets/library/story_book_card.dart';
import '../widgets/shared/static_background.dart';

class StoryLibraryScreen extends StatefulWidget {
  const StoryLibraryScreen({super.key});

  @override
  State<StoryLibraryScreen> createState() => _StoryLibraryScreenState();
}

class _StoryLibraryScreenState extends State<StoryLibraryScreen> 
    with SingleTickerProviderStateMixin {
  List<Story>? _stories;
  bool _isLoading = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Resume background music when entering library
    AudioService().resumeMusic();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    
    _loadStories();
  }

  Future<void> _loadStories() async {
    try {
      final stories = await StoryService.loadAllStories();
      setState(() {
        _stories = stories;
        _isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading stories: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

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
                        onPressed: () => Navigator.pop(context),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Title
                      Text(
                        'Story Library',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 32,
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Completed count
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_stories, size: 20),
                            const SizedBox(width: 8),
                            Consumer<GameProvider>(
                              builder: (context, provider, _) {
                                return Text(
                                  '${provider.completedStoriesCount}/${_stories?.length ?? 0}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Stories grid
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : _stories == null || _stories!.isEmpty
                          ? Center(
                              child: Text(
                                'No stories available',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            )
                          : FadeTransition(
                              opacity: _fadeAnimation,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40),
                                child: GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: 0.7,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20,
                                  ),
                                  itemCount: _stories!.length,
                                  itemBuilder: (context, index) {
                                    final story = _stories![index];
                                    return StoryBookCard(
                                      story: story,
                                      onTap: () => _openStory(story),
                                    );
                                  },
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

  void _openStory(Story story) {
    // Check if story is released
    if (story.status != null && story.status!.toLowerCase() == 'coming soon') {
      // Show coming soon message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${story.title} is coming soon! Stay tuned for more adventures!',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
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
    
    // Story is released - open it
    final gameProvider = context.read<GameProvider>();
    gameProvider.setCurrentStory(story);
    Navigator.pushNamed(context, '/reader');
  }
}
