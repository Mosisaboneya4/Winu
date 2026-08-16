# Period Tracker 🌸

A beautiful and simple period tracking app built with Flutter, featuring an elegant white and purple theme designed for ease of use.

## Features

- **Calendar View** - Interactive calendar to track your cycle
- **Period Logging** - Easily log when your period starts
- **Cycle Prediction** - Predicts next period and ovulation dates
- **Symptom Tracking** - Log and track common PMS symptoms
- **Customizable Settings** - Adjust cycle length and period duration
- **Data Persistence** - All data saved locally on your device
- **Beautiful UI** - Clean white and purple aesthetic design

## Screenshots

The app features:
- Summary cards showing next period date and ovulation window
- Color-coded calendar with period days highlighted
- Quick action buttons for logging period and symptoms
- Symptom chips with easy removal
- Settings for customizing cycle parameters

## Getting Started

### Prerequisites

- Flutter SDK (3.19.0 or higher)
- Android Studio / Xcode (for mobile development)
- Git

### Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd winu
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For Android
flutter run

# For iOS (macOS only)
flutter run
```

## Building the App

### Android APK
```bash
flutter build apk --release
```
The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`

### iOS IPA
```bash
flutter build ios --release
```

## GitHub Actions

This project includes automated build workflows via GitHub Actions:

- **Android Build** - Automatically builds release APK on push to main/master
- **iOS Build** - Automatically builds release IPA on push to main/master

Build artifacts are stored for 30 days and can be downloaded from the Actions tab.

### Manual Build Trigger
You can also trigger builds manually from the GitHub Actions tab using the "workflow_dispatch" option.

## App Configuration

### Default Settings
- Cycle Length: 28 days
- Period Length: 5 days
- These can be customized in the app settings

### Data Storage
All data is stored locally using `shared_preferences` package. No data is sent to external servers.

## Tech Stack

- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language
- **table_calendar** - Calendar widget
- **shared_preferences** - Local data persistence
- **intl** - Date formatting

## Customization

### Changing Colors
Edit `lib/main.dart` to modify the color scheme:
```dart
primaryColor: const Color(0xFF9B59B6),  // Main purple
secondary: const Color(0xFF8E44AD),     // Darker purple
```

### Adding More Symptoms
Edit `lib/screens/home_screen.dart` and add to the `_availableSymptoms` list.

## License

This project is created as a personal gift. Feel free to modify and use as needed.

## Support

For issues or questions, please create an issue in the repository.
