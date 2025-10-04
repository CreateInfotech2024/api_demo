# Quick Start Guide

## Getting Started in 5 Minutes

### Prerequisites
- Flutter SDK installed (version 3.8.0 or higher)
- Dart SDK
- IDE (VS Code, Android Studio, or IntelliJ IDEA)
- A physical device or emulator

### Step 1: Install Dependencies

```bash
cd api_demo
flutter pub get
```

### Step 2: Generate Code

```bash
flutter pub run build_runner build
```

### Step 3: Configure Backend

Edit `lib/config/api_config.dart`:

```dart
static const String baseUrl = 'https://krishnabarasiya.space'; // Your backend URL
```

### Step 4: Run the App

```bash
flutter run
```

## First Time Use

### Create Your First Meeting

1. **Open the app** - You'll see the home screen
2. **Fill the "Create New Meeting" form**:
   - Host Name: `Your Name`
   - Meeting Title: `Test Meeting`
   - Description: `My first meeting`
3. **Click "🚀 Create Meeting"**
4. **Note the meeting code** displayed at the top (e.g., `ABC123`)

### Join a Meeting

1. **Open the app on another device/emulator**
2. **Fill the "Join Existing Meeting" form**:
   - Meeting Code: `ABC123` (from step 4 above)
   - Your Name: `Participant Name`
3. **Click "🚀 Join Meeting"**

### Explore Features

**In the meeting:**
- 📹 Toggle video (blue camera icon)
- 🎤 Toggle audio (green microphone icon)
- 🖥️ Screen share (orange share icon)
- 💬 Open chat (purple chat icon)
- 📞 Leave meeting (red phone icon)

**Browse Courses:**
- Click "📚 Browse Courses" on home screen
- View Live, Scheduled, and Completed courses
- Click any course to join as Host or Participant

## Common Commands

```bash
# Run in development mode
flutter run

# Run on specific device
flutter devices              # List available devices
flutter run -d chrome        # Run on Chrome
flutter run -d <device-id>   # Run on specific device

# Build for production
flutter build apk           # Android APK
flutter build appbundle     # Android App Bundle
flutter build ios           # iOS
flutter build web           # Web

# Clean build
flutter clean
flutter pub get
flutter pub run build_runner build
flutter run

# Check for issues
flutter doctor
flutter analyze
```

## Troubleshooting Quick Fixes

### Problem: Build errors after git pull
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Problem: "Socket.IO not connecting"
1. Check `lib/config/api_config.dart` - verify `baseUrl`
2. Ensure backend server is running
3. Check network connectivity

### Problem: "Meeting code invalid"
- Meeting codes are exactly 6 characters
- Use uppercase letters
- Verify meeting exists on backend

### Problem: Permission errors
- Grant camera/microphone permissions when prompted
- Check app permissions in device settings

## Project Structure Overview

```
lib/
├── main.dart                    # App entry point
├── config/api_config.dart       # Backend configuration
├── models/                      # Data models
├── providers/app_provider.dart  # State management
├── screens/                     # UI screens
│   ├── home_screen.dart        # Create/join meeting
│   ├── course_list_screen.dart # Browse courses
│   └── meeting_screen.dart     # Active meeting
├── services/                    # Backend services
│   ├── api_service.dart        # REST API
│   └── websocket_service.dart  # WebSocket/Socket.IO
└── widgets/                     # Reusable components
```

## Key Files to Customize

1. **Backend URL**: `lib/config/api_config.dart`
2. **App Theme**: `lib/main.dart` (ThemeData)
3. **API Endpoints**: `lib/config/api_config.dart`

## Testing Multi-Participant Meetings

### Option 1: Multiple Emulators
```bash
# Terminal 1
flutter run -d emulator-5554

# Terminal 2
flutter run -d emulator-5556
```

### Option 2: Web + Mobile
```bash
# Terminal 1
flutter run -d chrome

# Terminal 2
flutter run -d <phone-device-id>
```

### Option 3: Multiple Physical Devices
```bash
flutter devices  # List all connected devices
flutter run -d <device-id>  # Run on specific device
```

## Next Steps

1. ✅ **Read COMPLETE_GUIDE.md** for detailed documentation
2. ✅ **Check API_ENDPOINTS.md** for backend integration
3. ✅ **Review IMPLEMENTATION_SUMMARY.md** for technical details
4. ✅ **Explore the code** in `lib/` directory

## Support

- 📚 Check the [Complete Guide](COMPLETE_GUIDE.md)
- 🔧 Review [API Endpoints](API_ENDPOINTS.md)
- 💡 See [Implementation Summary](IMPLEMENTATION_SUMMARY.md)

---

**Happy Coding! 🚀**
