import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story_page.dart';
import '../providers/game_provider.dart';
import '../services/story_service.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../services/voice_service.dart';
import '../widgets/shared/static_background.dart';
import '../widgets/reader/story_navigation_header.dart';
import '../widgets/reader/story_page_content.dart';
import '../widgets/reader/story_quiz_dialog.dart';

class StoryReaderScreen extends StatefulWidget {
  final VoidCallback? onStoryComplete;
  final bool isOnboarding;
  
  const StoryReaderScreen({
    super.key,
    this.onStoryComplete,
    this.isOnboarding = false,
  });

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> with SingleTickerProviderStateMixin {
  int _currentTextIndex = 0; // 0 = left, 1 = right, 2 = next page
  bool _showTapHint = false;
  bool _leftDone = false;
  bool _rightDone = false;
  AnimationController? _pageTransitionController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize page transition animations
    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController!,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController!,
      curve: Curves.easeOutCubic,
    ));
    
    // Pause background music for story reading
    AudioService().pauseMusic();
    
    // Defer story loading until after build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStory();
    });
  }
  
  @override
  void dispose() {
    _pageTransitionController?.dispose();
    // Stop voiceover and resume background music when leaving story reader
    VoiceService().stopVoiceover();
    AudioService().resumeMusic();
    super.dispose();
  }

  Future<void> _loadStory() async {
    final provider = context.read<GameProvider>();
    
    // If onboarding mode, use the story already set by OnboardingService
    // Otherwise use the story from GameProvider (set by library screen)
    final story = widget.isOnboarding 
        ? (StoryService.currentStory ?? await StoryService.loadTestStory())
        : (provider.currentStory ?? await StoryService.loadTestStory());
    
    // Only set if not already set (avoid overriding library selection)
    if (provider.currentStory != story) {
      provider.setCurrentStory(story);
    }
    _currentTextIndex = 0; // Reset text index

    // Show tap hint only the first time per story (skip for onboarding)
    final seen = widget.isOnboarding ? true : StorageService.hasSeenTapHintForStory(story.id);
    setState(() {
      _showTapHint = !seen;
    });
    
    // Start with page fully visible
    _pageTransitionController?.forward();
  }

  void _handleTap() {
    final provider = context.read<GameProvider>();
    final story = provider.currentStory;
    if (story == null) return;
    
    final page = story.pages[provider.currentPageIndex];
    
    
    // Gate taps while streaming
    if (_currentTextIndex == 1 && !_leftDone) {
      return;
    }
    if (_currentTextIndex == 2) {
      final hasRightText = (page.rightBottomText != null && page.rightBottomText!.isNotEmpty) ||
          (page.rightUpText != null && page.rightUpText!.isNotEmpty) ||
          false;
      if (hasRightText && !_rightDone) {
        return;
      }
    }

    setState(() {
      if (_currentTextIndex == 0) {
        // First tap - check if there's any first position text
        final hasFirstText = (page.leftBottomText != null && page.leftBottomText!.isNotEmpty) ||
            (page.leftCenterText != null && page.leftCenterText!.isNotEmpty) ||
            (page.rightCenterText != null && page.rightCenterText!.isNotEmpty) ||
            (page.centreBottomText != null && page.centreBottomText!.isNotEmpty);
        
        if (hasFirstText) {
          _currentTextIndex = 1;
          _leftDone = false;
        } else {
          // No first text, check for second position text only
          final hasSecondText = (page.rightBottomText != null && page.rightBottomText!.isNotEmpty) ||
              (page.rightUpText != null && page.rightUpText!.isNotEmpty) ||
              (page.leftUpText != null && page.leftUpText!.isNotEmpty);
          
          if (hasSecondText) {
            _currentTextIndex = 2;
            _rightDone = false;
          } else {
            _moveToNextPageOrEnd(provider);
          }
        }
      } else if (_currentTextIndex == 1) {
        // Second tap - show right text or move to next page
        if (page.rightBottomText != null && page.rightBottomText!.isNotEmpty) {
          _currentTextIndex = 2;
          _rightDone = false;
        } else if (page.rightUpText != null && page.rightUpText!.isNotEmpty) {
          _currentTextIndex = 2;
          _rightDone = false;
        } else if (page.leftUpText != null && page.leftUpText!.isNotEmpty) {
          _currentTextIndex = 2;
          _rightDone = false; // will use leftUp as the second text
        } else {
          // No second text available, move to next page or end story
          _moveToNextPageOrEnd(provider);
        }
      } else {
        // Third tap - move to next page or end story
        _moveToNextPageOrEnd(provider);
      }
    });
  }



  void _moveToNextPageOrEnd(GameProvider provider) {
    if (!provider.isLastPage) {
      // Stop any playing voiceover before changing page
      VoiceService().stopVoiceover();
      
      // Start fade out animation
      _pageTransitionController?.reverse().then((_) {
        // Change page when fade out completes
        provider.nextPage();
        _currentTextIndex = 0;
        _leftDone = false;
        _rightDone = false;
        
        // Fade back in with new page
        _pageTransitionController?.forward();
        
        // Once the user has progressed, hide the hint for this story going forward
        final storyId = provider.currentStory?.id;
        if (storyId != null) {
          StorageService.setSeenTapHintForStory(storyId);
        }
      });
      setState(() {
        _showTapHint = false;
      });
    } else {
      // Story has ended - stop voiceover and check for quiz
      VoiceService().stopVoiceover();
      final storyId = provider.currentStory?.id;
      if (storyId != null) {
        provider.completeStory(storyId);
      }
      
      // Check if story has a quiz
      _checkAndShowQuiz();
    }
  }

  void _checkAndShowQuiz() async {
    final provider = context.read<GameProvider>();
    final story = provider.currentStory;
    if (story == null) return;

    // Get quiz directly from story object
    final quiz = story.quiz;

    // Skip quiz for onboarding
    if (widget.isOnboarding) {
      _showStoryEndDialog();
      return;
    }

    if (quiz != null && mounted) {
      // Show quiz before completion dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StoryQuizDialog(
            quiz: quiz,
            onComplete: () {
              // After quiz, show completion dialog
              _showStoryEndDialog();
            },
          );
        },
      );
    } else {
      // No quiz, show completion dialog directly
      _showStoryEndDialog();
    }
  }

  void _showStoryEndDialog() {
    // If there's a custom completion callback (e.g., for onboarding), use it
    if (widget.onStoryComplete != null) {
      widget.onStoryComplete!();
      return;
    }
    
    // Skip completion dialog - go back to library immediately after quiz
    Navigator.of(context).pop(); // Go back to library
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const StaticBackground(),
          // Full screen page content without SafeArea or padding
          Consumer<GameProvider>(
            builder: (context, provider, _) {
              final story = provider.currentStory;
              if (story == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final pageIndex = provider.currentPageIndex;
              final StoryPage page = story.pages[pageIndex];

              return Stack(
                children: [
                  // Animated page content - full screen
                  Positioned.fill(
                    child: FadeTransition(
                      opacity: _fadeAnimation!,
                      child: SlideTransition(
                        position: _slideAnimation!,
                        child: GestureDetector(
                          onTap: _handleTap,
                          child: StoryPageContent(
                            page: page,
                            currentTextIndex: _currentTextIndex,
                            leftDone: _leftDone,
                            rightDone: _rightDone,
                            showTapHint: _showTapHint,
                            onLeftDone: () {
                              if (mounted) {
                                setState(() {
                                  _leftDone = true;
                                });
                              }
                            },
                            onRightDone: () {
                              if (mounted) {
                                setState(() {
                                  _rightDone = true;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          // Navigation header - hide during onboarding
          if (!widget.isOnboarding)
            Consumer<GameProvider>(
              builder: (context, provider, _) {
                final story = provider.currentStory;
                if (story == null) return const SizedBox.shrink();
                
                return Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 0,
                  right: 0,
                  child: StoryNavigationHeader(
                    currentPage: provider.currentPageIndex + 1,
                    totalPages: story.pages.length,
                    onBack: () => Navigator.pop(context),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
