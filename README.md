# Beauty LMS - Video Conferencing App 💄

A complete **Zoom-like video conferencing and course management system** built with Flutter. This application provides real-time meeting capabilities, course integration, chat functionality, and comprehensive media controls.

![Flutter](https://img.shields.io/badge/Flutter-3.8.0+-02569B?style=flat&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat&logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Key Features

- 🎥 **Meeting Management**: Create and join meetings with unique codes
- 👥 **Real-Time Participants**: Live participant list with host identification
- 💬 **Live Chat**: Real-time messaging with system notifications
- 🎛️ **Media Controls**: Toggle video, audio, and screen sharing
- 📚 **Course Integration**: Browse and join live/scheduled/completed courses
- 🔄 **WebSocket Communication**: Real-time updates via Socket.IO
- 🎨 **Modern UI**: Beautiful, responsive interface with Material Design

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/CreateInfotech2024/api_demo.git
cd api_demo

# Install dependencies
flutter pub get

# Generate code
flutter pub run build_runner build

# Run the app
flutter run
```

**First meeting in 30 seconds:**
1. Open the app
2. Fill "Create New Meeting" form
3. Click "🚀 Create Meeting"
4. Share the meeting code with others!

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [📖 Quick Start](QUICKSTART.md) | Get started in 5 minutes |
| [📘 Complete Guide](COMPLETE_GUIDE.md) | Comprehensive documentation |
| [✅ Features](FEATURES.md) | Complete feature checklist |
| [🔌 API Endpoints](API_ENDPOINTS.md) | Backend API documentation |
| [⚙️ Implementation](IMPLEMENTATION_SUMMARY.md) | Technical implementation details |
| [🧪 Testing Guide](TESTING_GUIDE.md) | Testing procedures |

## 🎯 What's Included

### ✅ Core Functionality
- **Meeting Lifecycle**: Create, join, and leave meetings
- **Host & Participant Roles**: Different permissions and indicators
- **Real-Time Sync**: Participant updates, chat, media states
- **Course Management**: Browse and join courses
- **Media Controls**: Video, audio, screen share toggles
- **Chat System**: Real-time messaging with timestamps

### ✅ User Interface
- **Home Screen**: Create/join meeting forms
- **Course Screen**: Browse courses with filters
- **Meeting Screen**: Participant grid, chat panel, controls
- **Responsive Design**: Adapts to different screen sizes
- **Loading & Error States**: Professional feedback

### ✅ Technical Stack
- **State Management**: Provider pattern
- **API Communication**: REST API with http package
- **Real-Time**: WebSocket with Socket.IO client
- **JSON Serialization**: Automatic code generation
- **UI Components**: Flutter Material Design

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS  
- ✅ Web
- ✅ Windows (experimental)
- ✅ macOS (experimental)
- ✅ Linux (experimental)

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point
├── config/api_config.dart            # Backend configuration
├── models/                           # Data models
│   ├── meeting.dart                  # Meeting, Participant, ChatMessage
│   └── course.dart                   # Course data
├── providers/app_provider.dart       # State management
├── screens/                          # UI screens
│   ├── home_screen.dart             # Create/join meetings
│   ├── course_list_screen.dart      # Browse courses
│   └── meeting_screen.dart          # Active meeting
├── services/                         # Backend services
│   ├── api_service.dart             # REST API client
│   ├── websocket_service.dart       # Socket.IO client
│   └── webrtc_service.dart          # WebRTC P2P streaming
├── utils/                            # Utilities
│   └── permission_helper.dart       # Permission handling
└── widgets/                          # Reusable components
    ├── common/                       # Shared widgets
    ├── course/                       # Course widgets
    └── meeting/                      # Meeting widgets
```

## 🔧 Configuration

Edit `lib/config/api_config.dart` to configure your backend:

```dart
class ApiConfig {
  static const String baseUrl = 'https://krishnabarasiya.space';
  static const String apiPath = '/api';
  // ... other configuration
}
```

## 🎮 Usage Examples

### Create a Meeting
```dart
// As Host
final provider = context.read<AppProvider>();
await provider.createMeeting(
  hostName: 'John Doe',
  title: 'Team Standup',
  description: 'Daily sync meeting',
);
// Navigate to meeting screen
Navigator.pushNamed(context, '/meeting');
```

### Join a Meeting
```dart
// As Participant
final provider = context.read<AppProvider>();
await provider.joinMeeting(
  meetingCode: 'ABC123',
  participantName: 'Jane Smith',
);
// Navigate to meeting screen
Navigator.pushNamed(context, '/meeting');
```

### Toggle Media
```dart
// Toggle video
provider.toggleVideo();

// Toggle audio
provider.toggleAudio();

// Toggle screen sharing
provider.toggleScreenSharing();
```

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📋 Requirements

- Flutter SDK: 3.8.0 or higher
- Dart SDK: 3.0 or higher
- Backend server running (see API_ENDPOINTS.md)

## 🐛 Troubleshooting

**Socket not connecting?**
- Check backend URL in `lib/config/api_config.dart`
- Verify backend server is running
- Check network/firewall settings

**Build errors?**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

See [QUICKSTART.md](QUICKSTART.md#troubleshooting-quick-fixes) for more solutions.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- CreateInfotech2024 - Initial work

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Socket.IO for real-time communication
- All contributors and supporters

## 📞 Support

For support, email support@example.com or open an issue in the repository.

---

**⭐ Star this repo if you find it helpful!**

Made with ❤️ using Flutter
