import 'package:flutter/material.dart';
import '../core/constants/routes.dart';
import '../services/onboarding_service.dart';
import '../services/story_service.dart';
import '../services/audio_service.dart';
import 'story_reader_screen.dart';

/// Onboarding screen that uses the story reader for reusability
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOnboarding();
  }

  Future<void> _loadOnboarding() async {
    try {
      final story = await OnboardingService.loadOnboardingStory();
      
      // Set as current story so the reader screen can use it
      StoryService.setCurrentStory(story);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load onboarding: $e';
        _isLoading = false;
      });
    }
  }

  void _onOnboardingComplete() {
    // Mark onboarding as complete
    OnboardingService.markOnboardingComplete();
    
    // Navigate to the main app (cosmic hub)
    Navigator.of(context).pushReplacementNamed(Routes.hub);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  AudioService().playSfx('button');
                  Navigator.of(context).pushReplacementNamed('/hub');
                },
                child: const Text('Skip to App'),
              ),
            ],
          ),
        ),
      );
    }

    // Use the story reader screen but customize the completion behavior
    return WillPopScope(
      onWillPop: () async {
        // Prevent going back during onboarding
        return false;
      },
      child: StoryReaderScreen(
        onStoryComplete: _onOnboardingComplete,
        isOnboarding: true,
      ),
    );
  }
}
