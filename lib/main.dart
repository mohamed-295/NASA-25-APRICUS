import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/routes.dart';
import 'providers/game_provider.dart';
import 'screens/cosmic_hub_screen.dart';
import 'screens/story_library_screen.dart';
import 'screens/story_reader_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock to landscape orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Enable fullscreen mode - hide system UI completely
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );
  
  // Set system UI overlay style for transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Ensure system UI stays hidden
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GameProvider()..loadSettings(),
        ),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: MaterialApp(
          title: 'Apricus - Space Weather Adventures',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          initialRoute: Routes.splash,
          routes: {
            Routes.splash: (context) => const SplashScreen(),
            Routes.hub: (context) => const CosmicHubScreen(),
            Routes.library: (context) => const StoryLibraryScreen(),
            Routes.reader: (context) => const StoryReaderScreen(),
            Routes.settings: (context) => const SettingsScreen(),
          },
        ),
      ),
    );
  }
}