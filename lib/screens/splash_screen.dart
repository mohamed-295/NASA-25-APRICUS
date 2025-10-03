import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/routes.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;
  bool _initDone = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.9, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    _boot();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _initDone && mounted) {
        Navigator.of(context).pushReplacementNamed(Routes.hub);
      }
    });
  }

  Future<void> _boot() async {
    // Keep status bar transparent for splash
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));

    // Perform app init while splash is visible
    await StorageService.init();
    await AudioService().init();

    _initDone = true;
    if (!mounted) return;
    // If animation already finished, navigate now
    if (_controller.status == AnimationStatus.completed) {
      Navigator.of(context).pushReplacementNamed(Routes.hub);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Simple animated logo/title
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: SizedBox(
                  height: 300,
                  child: Image.asset(
                    'assets/images/splash_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // Progress indicator at bottom
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                        value: _controller.value,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Loading...',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white70),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


