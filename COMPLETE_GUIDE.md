# Complete Guide: Zoom-Like Video Conferencing App

## Overview
This Flutter application provides a complete Zoom-like video conferencing and course management system. It includes features for creating meetings, joining meetings, real-time chat, participant management, and media controls (audio, video, screen sharing).

## Architecture

### Backend Communication
- **REST API**: Used for creating/joining meetings and course management
- **WebSocket (Socket.IO)**: Used for real-time communication (chat, participant updates, media control events)
- **SFU (Selective Forwarding Unit)**: Backend architecture for efficient video streaming

### Flutter Architecture
- **Provider Pattern**: State management using the Provider package
- **Service Layer**: Separated API and WebSocket services
- **Widget Composition**: Reusable widgets for consistent UI

## Key Features

### 1. Meeting Management
- ✅ Create new meetings as host
- ✅ Join existing meetings with meeting code
- ✅ Display meeting information (title, code, participants)
- ✅ Leave meetings with confirmation dialog
- ✅ Real-time participant list updates

### 2. Course Integration
- ✅ Browse live, scheduled, and completed courses
- ✅ Join courses as host or participant
- ✅ Automatic meeting creation for course sessions
- ✅ Course status tracking (live, scheduled, completed)

### 3. Real-Time Chat
- ✅ Send and receive messages instantly
- ✅ System messages for participant join/leave events
- ✅ Screen sharing notifications
- ✅ Auto-scroll to latest messages
- ✅ Timestamp display for each message

### 4. Media Controls
- ✅ Video on/off toggle
- ✅ Audio (microphone) on/off toggle
- ✅ Screen sharing start/stop
- ✅ Real-time media state synchronization across participants
- ✅ Visual indicators for media states

### 5. User Interface
- ✅ Participant grid view (1, 4, 9, or 16+ participant layouts)
- ✅ Host indicators (yellow border and badge)
- ✅ Audio/video status indicators
- ✅ Toggle between video grid and chat panel
- ✅ Connection status display
- ✅ Loading states and error handling

## Application Structure

```
lib/
├── main.dart                          # App entry point
├── config/
│   └── api_config.dart               # API endpoints and configuration
├── models/
│   ├── api_response.dart             # Generic API response wrapper
│   ├── course.dart                   # Course data model
│   ├── course.g.dart                 # Generated JSON serialization
│   ├── meeting.dart                  # Meeting, Participant, ChatMessage models
│   └── meeting.g.dart                # Generated JSON serialization
├── providers/
│   └── app_provider.dart             # Main state management provider
├── screens/
│   ├── home_screen.dart              # Create/join meeting screen
│   ├── course_list_screen.dart       # Browse and join courses
│   └── meeting_screen.dart           # Active meeting interface
├── services/
│   ├── api_service.dart              # REST API client
│   └── websocket_service.dart        # Socket.IO client
└── widgets/
    ├── common/
    │   ├── loading_widget.dart       # Reusable loading indicator
    │   └── error_widget.dart         # Reusable error display
    ├── course/
    │   └── course_card.dart          # Course list item
    └── meeting/
        ├── participant_grid.dart     # Participant video grid
        ├── chat_panel.dart           # Chat interface
        └── meeting_controls.dart     # Media control buttons
```

## Usage Guide

### Creating a Meeting (As Host)

1. Open the app and navigate to the home screen
2. Fill in the "Create New Meeting" form:
   - **Host Name**: Your name
   - **Meeting Title**: Title for the meeting
   - **Description**: Brief description
3. Click "🚀 Create Meeting"
4. You'll be redirected to the meeting screen with a unique meeting code
5. Share the meeting code with participants

**Code Flow:**
```dart
// User fills form → AppProvider.createMeeting()
// → API call to create meeting → WebSocket joins meeting room
// → Navigation to meeting screen
```

### Joining a Meeting (As Participant)

1. Open the app and navigate to the home screen
2. Fill in the "Join Existing Meeting" form:
   - **Meeting Code**: 6-character code from host
   - **Your Name**: Your display name
3. Click "🚀 Join Meeting"
4. You'll join the active meeting

**Code Flow:**
```dart
// User enters code → AppProvider.joinMeeting()
// → API call to join meeting → WebSocket joins meeting room
// → Receive participant list → Navigation to meeting screen
```

### Joining via Courses

1. Navigate to the Courses screen (📚 Browse Courses)
2. Browse available courses in tabs (Live/Scheduled/Completed)
3. Click on a course card
4. In the modal, enter your name and select role:
   - **Join as Host/Instructor**: Creates a new meeting
   - **Join as Participant**: Joins existing meeting
5. Click "Continue"

**Code Flow:**
```dart
// User selects course → Shows join dialog
// If Host: AppProvider.createMeeting() with course details
// If Participant: AppProvider.joinMeeting() with course meeting code
// → Navigation to meeting screen
```

### In-Meeting Actions

#### Toggle Video
- Click the video camera button in the control bar
- Blue = On, Red = Off
- Other participants see your video state update in real-time

#### Toggle Audio
- Click the microphone button in the control bar
- Green = On, Red = Off
- Other participants see your audio state update in real-time

#### Screen Sharing
- Click the screen share button
- Orange = Sharing, Grey = Not sharing
- System message appears in chat when you start/stop sharing

#### Chat
- Click the chat button to toggle between video grid and chat
- Type message and press Send or Enter
- Messages appear instantly for all participants
- System messages show join/leave events

#### Leave Meeting
- Click the red "Leave" button
- Confirm in the dialog
- You'll return to the home screen
- Other participants are notified of your departure

## WebSocket Events

### Client → Server Events

```dart
// Join meeting
socket.emit('joinMeeting', {
  'meetingCode': 'ABC123',
  'participantId': 'user_123',
  'participantName': 'John Doe'
});

// Send chat message
socket.emit('sendMessage', {
  'meetingCode': 'ABC123',
  'senderId': 'user_123',
  'senderName': 'John Doe',
  'message': 'Hello!',
  'timestamp': '2024-01-01T10:00:00Z'
});

// Toggle video
socket.emit('toggle-video', {
  'meetingCode': 'ABC123',
  'participantId': 'user_123',
  'enabled': false
});

// Toggle audio
socket.emit('toggle-audio', {
  'meetingCode': 'ABC123',
  'participantId': 'user_123',
  'enabled': true
});

// Start screen sharing
socket.emit('start-screen-share', {
  'meetingCode': 'ABC123',
  'participantId': 'user_123'
});
```

### Server → Client Events

```dart
// Participant joined
socket.on('participant-joined', (data) {
  // Update participant list
  // Show system message in chat
});

// Participant left
socket.on('participant-left', (data) {
  // Update participant list
  // Show system message in chat
});

// Receive chat message
socket.on('receiveMessage', (data) {
  // Add message to chat
});

// Participant audio toggle
socket.on('participant-audio-toggle', (data) {
  // Update participant's audio state
});

// Participant video toggle
socket.on('participant-video-toggle', (data) {
  // Update participant's video state
});

// Screen share started
socket.on('screen-share-started', (data) {
  // Show system message
  // Update UI for screen sharing
});

// Screen share stopped
socket.on('screen-share-stopped', (data) {
  // Show system message
  // Update UI
});
```

## State Management Flow

### AppProvider (Main State Container)

```dart
class AppProvider extends ChangeNotifier {
  // Connection state
  bool _isConnected = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Meeting state
  Meeting? _currentMeeting;
  String? _currentParticipantId;
  List<ChatMessage> _chatMessages = [];
  
  // Media control states
  bool _isVideoEnabled = true;
  bool _isAudioEnabled = true;
  bool _isScreenSharing = false;
  
  // Courses
  List<Course> _courses = [];
}
```

### State Updates

1. **User Action** → Widget calls provider method
2. **Provider Method** → Calls service (API/WebSocket)
3. **Service Response** → Provider updates state
4. **notifyListeners()** → All listening widgets rebuild
5. **UI Updates** → User sees changes

Example:
```dart
// User clicks toggle video button
onPressed: () => provider.toggleVideo()

// Provider toggles state and notifies backend
void toggleVideo() {
  _isVideoEnabled = !_isVideoEnabled;
  _wsService.emitMediaToggle(...);
  notifyListeners(); // UI updates
}
```

## API Endpoints

### REST API

```
Base URL: https://krishnabarasiya.space

GET  /api/health                        # Health check
GET  /api/live_courses                  # Get all courses
POST /api/meeting                       # Create meeting
POST /api/meeting/:code/join            # Join meeting
POST /api/meeting/:code/leave           # Leave meeting
GET  /api/meeting/:code                 # Get meeting details
POST /api/meeting/:code/chat            # Send chat message
```

### WebSocket URL

```
wss://krishnabarasiya.space
```

## Error Handling

### Connection Errors
- App shows connection status indicator
- Red = Disconnected, Green = Connected
- Automatic reconnection attempts

### API Errors
- Loading states prevent duplicate requests
- Error messages displayed in UI
- Retry functionality available

### Meeting Errors
- Invalid meeting code → Error message
- Network issues → Graceful degradation
- Validation errors → Form field errors

## Testing

### Local Testing
1. Run the Flutter app: `flutter run`
2. Open multiple instances for multi-participant testing
3. Create meeting on one device
4. Join with meeting code on another device

### Backend Testing
1. Ensure backend server is running at configured URL
2. Check API endpoints with tools like Postman
3. Verify WebSocket connections with Socket.IO client

### Physical Device Testing
1. Build and install on physical devices
2. Test camera/microphone permissions
3. Test screen sharing (limited on mobile)
4. Test network conditions (WiFi, cellular)

## Dependencies

```yaml
dependencies:
  flutter: sdk
  provider: ^6.1.0              # State management
  http: ^1.1.0                  # REST API calls
  socket_io_client: ^2.0.3+1    # WebSocket/Socket.IO
  json_annotation: ^4.8.1       # JSON serialization
  intl: ^0.18.0                 # Date/time formatting
  flutter_spinkit: ^5.2.0       # Loading indicators
  shared_preferences: ^2.2.2    # Local storage
  video_player: ^2.8.1          # Video playback
  flutter_webrtc: ^0.9.48       # WebRTC support
  permission_handler: ^11.0.1   # Permissions
  path_provider: ^2.1.1         # File system access
  cached_network_image: ^3.3.0  # Image caching
  fluttertoast: ^8.2.4          # Toast messages

dev_dependencies:
  build_runner: ^2.4.7          # Code generation
  json_serializable: ^6.7.1     # JSON code generation
  flutter_lints: ^5.0.0         # Linting
```

## Build and Run

### Development
```bash
# Get dependencies
flutter pub get

# Generate code (for JSON serialization)
flutter pub run build_runner build

# Run on device/emulator
flutter run

# Run with specific device
flutter run -d chrome  # Web
flutter run -d <device-id>  # Specific device
```

### Production Build
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Troubleshooting

### "Socket.IO not connecting"
- Check backend URL in `lib/config/api_config.dart`
- Verify backend server is running
- Check network/firewall settings

### "Meeting code not working"
- Ensure meeting code is exactly 6 characters
- Verify meeting exists on backend
- Check API endpoint configuration

### "Video/audio not working"
- Grant camera/microphone permissions
- Check device compatibility
- Verify WebRTC implementation on backend

### "Chat messages not appearing"
- Check WebSocket connection status
- Verify Socket.IO events are properly configured
- Check backend event handlers

## Future Enhancements

### Potential Features
- [ ] Actual WebRTC video/audio streams (currently UI only)
- [ ] Recording functionality
- [ ] Breakout rooms
- [ ] Polls and reactions
- [ ] Virtual backgrounds
- [ ] Hand raise feature
- [ ] Participant management (mute all, remove participant)
- [ ] Meeting scheduling
- [ ] Push notifications
- [ ] Meeting history
- [ ] Analytics dashboard

### Technical Improvements
- [ ] Offline mode support
- [ ] Better error recovery
- [ ] Performance optimizations
- [ ] Accessibility improvements
- [ ] Internationalization (i18n)
- [ ] Unit and integration tests
- [ ] CI/CD pipeline

## Contributing

When contributing to this project:
1. Follow Flutter/Dart style guidelines
2. Maintain the existing architecture
3. Add appropriate comments
4. Test on multiple devices
5. Update documentation

## License

[Add your license information here]

## Support

For issues or questions:
- Check the documentation
- Review API endpoint documentation (`API_ENDPOINTS.md`)
- Check implementation summary (`IMPLEMENTATION_SUMMARY.md`)
- Contact the development team

---

**Note**: This is a demonstration project. For production use, ensure proper security measures, data validation, authentication, and authorization are implemented on the backend.
