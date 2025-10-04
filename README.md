# 🌟 Apricus - Space Weather Adventures

An educational Flutter app that teaches kids about space weather through interactive stories, mini-games, and engaging animations.

## 📱 Download

**[Download Apricus APK](https://drive.google.com/file/d/1n6_tJdQxvTnFImcrp9FMMa-AeFcTNbR-/view?usp=drive_link)**

## ✨ Features

### 📚 Interactive Story Library
- Read engaging space weather adventures with animated characters
- Text streaming effects for immersive reading experience
- Character voiceovers and sound effects
- Story completion tracking and achievements

### 🎮 Educational Mini-Games
- **Aurora Creator**: Learn how solar wind creates beautiful auroras
- Scientific explanations integrated into gameplay
- Unlock games by completing related stories
- Score tracking and victory animations

### 🎵 Rich Audio Experience
- Background music with dynamic controls
- Character voiceovers for enhanced storytelling
- Sound effects for buttons and interactions
- Customizable audio settings (music, SFX, voiceover, volume)

### 🎨 Beautiful UI/UX
- Animated space-themed backgrounds
- Smooth page transitions and character animations
- Responsive design for landscape mode
- Custom fonts and color themes
- Immersive fullscreen experience

### 🔧 Settings & Persistence
- Volume controls for music and sound effects
- Toggle options for all audio features
- Settings persist across app restarts
- Progress tracking for completed stories

## 🏗️ Project Structure

```
lib/
├── core/                 # Constants, theme, routes
├── models/              # Data structures (Story, Quiz, etc.)
├── providers/           # State management (GameProvider)
├── screens/             # Main UI screens
│   ├── cosmic_hub_screen.dart       # Main menu
│   ├── story_library_screen.dart    # Browse stories
│   ├── story_reader_screen.dart     # Read stories
│   ├── games_screen.dart            # Browse mini-games
│   ├── settings_screen.dart         # App settings
│   └── games/                       # Mini-game screens
├── services/            # Audio, storage, story services
└── widgets/             # Reusable UI components
    ├── reader/          # Story reading components
    ├── library/         # Story browsing components
    ├── hub/             # Main menu components
    └── shared/          # Common widgets
```

## 📊 Code Statistics

- **Total Lines**: ~4,592 lines of Dart code
- **Files**: 37 Dart files
- **Architecture**: Clean separation of concerns with services, models, and UI layers

## 🛠️ Technologies Used

- **Flutter SDK**: Cross-platform mobile development
- **Provider**: State management
- **just_audio**: Audio playback (music, SFX, voiceovers)
- **shared_preferences**: Local data persistence
- **Custom animations**: Smooth UI transitions

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / VS Code with Flutter extensions
- Android device or emulator

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd apricus
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## 👥 Team DRACO

- Hana Ahmed Saeed
- Mohamed Adel Mohamed
- Nadine Haytham FathAllah
- Ayman Yasser Ahmed
- Awwab Khalil Ahmed

## 📝 License

This project is developed as an educational tool for teaching kids about space weather phenomena.

## 🎯 Educational Goals

Apricus aims to:
- Teach children about space weather concepts (solar wind, auroras, magnetic fields)
- Make science fun and interactive through storytelling
- Encourage curiosity about space and astronomy
- Provide age-appropriate educational content with engaging visuals

---

**Made with ❤️ by Team DRACO**
