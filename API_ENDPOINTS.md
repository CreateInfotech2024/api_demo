# Video Calling API Endpoints Documentation

## Overview
This document outlines the API endpoints and WebRTC signaling architecture for the Google Meet/Zoom-like video calling application with SFU (Selective Forwarding Unit) backend support.

## Base Configuration

- **API Base URL**: `https://krishnabarasiya.space/api`
- **Socket.IO URL**: `https://krishnabarasiya.space`
- **Transport**: WebSocket with polling fallback
- **Authentication**: Bearer token (when available)

## REST API Endpoints

### Live Courses Management

#### Get All Live Courses
```http
GET /api/live_courses
```
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "course_id",
      "name": "Course Name",
      "description": "Course description",
      "instructorId": "instructor_id",
      "instructorName": "Instructor Name",
      "category": "Category",
      "status": "scheduled|active|completed",
      "scheduledDateTime": "2024-01-01T10:00:00Z",
      "duration": 60,
      "enrolledUsers": ["user1", "user2"],
      "joinedUsers": ["user1"],
      "recordingEnabled": true,
      "meetingCode": "MEET123",
      "meetingId": "meeting_id",
      "createdAt": "2024-01-01T09:00:00Z",
      "updatedAt": "2024-01-01T09:30:00Z"
    }
  ]
}
```

#### Create Live Course
```http
POST /api/live_courses
Content-Type: application/json

{
  "name": "New Course",
  "description": "Course description",
  "instructorId": "instructor_id",
  "instructorName": "Instructor Name",
  "category": "Category",
  "scheduledDateTime": "2024-01-01T10:00:00Z",
  "duration": 60,
  "recordingEnabled": true
}
```

#### Join Live Course
```http
POST /api/live_courses/{courseId}/join
Content-Type: application/json

{
  "participantId": "participant_id",
  "participantName": "Participant Name"
}
```

#### Leave Live Course
```http
POST /api/live_courses/{courseId}/leave
Content-Type: application/json

{
  "participantId": "participant_id"
}
```

#### Complete Live Course
```http
POST /api/live_courses/{courseId}/complete
Content-Type: application/json

{
  "instructorId": "instructor_id"
}
```

### Health Check
```http
GET /api/health
```
**Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T10:00:00Z",
  "services": {
    "api": "healthy",
    "database": "healthy",
    "websocket": "healthy"
  }
}
```

## WebSocket/Socket.IO Events

### Connection Events

#### Connect to Server
```javascript
// Client connects to socket server
socket.connect()

// Server response
socket.on('connect', () => {
  console.log('Connected to server');
});
```

#### Join Meeting Room
```javascript
// Client emits
socket.emit('join-meeting', {
  meetingCode: 'MEET123',
  participantId: 'participant_id',
  participantName: 'John Doe',
  isHost: false,
  timestamp: '2024-01-01T10:00:00Z'
});

// Server broadcasts to room
socket.on('participant-joined', {
  participantId: 'participant_id',
  participantName: 'John Doe',
  isHost: false,
  joinedAt: '2024-01-01T10:00:00Z',
  meetingCode: 'MEET123'
});
```

#### Leave Meeting Room
```javascript
// Client emits
socket.emit('leave-meeting', {
  meetingCode: 'MEET123',
  participantName: 'John Doe',
  timestamp: '2024-01-01T10:00:00Z'
});

// Server broadcasts to room
socket.on('participant-left', {
  participantId: 'participant_id',
  participantName: 'John Doe',
  leftAt: '2024-01-01T10:00:00Z',
  meetingCode: 'MEET123'
});
```

### WebRTC Signaling Events

#### Offer/Answer Exchange
```javascript
// Send offer
socket.emit('offer', {
  offer: {
    sdp: 'sdp_string',
    type: 'offer'
  },
  to: 'target_participant_id'
});

// Receive offer
socket.on('offer', (data) => {
  const { offer, from } = data;
  // Handle offer and create answer
});

// Send answer
socket.emit('answer', {
  answer: {
    sdp: 'sdp_string',
    type: 'answer'
  },
  to: 'target_participant_id'
});

// Receive answer
socket.on('answer', (data) => {
  const { answer, from } = data;
  // Handle answer
});
```

#### ICE Candidate Exchange
```javascript
// Send ICE candidate
socket.emit('ice-candidate', {
  candidate: {
    candidate: 'candidate_string',
    sdpMid: 'sdp_mid',
    sdpMLineIndex: 0
  },
  to: 'target_participant_id'
});

// Receive ICE candidate
socket.on('ice-candidate', (data) => {
  const { candidate, from } = data;
  // Add ICE candidate to peer connection
});
```

### Media Control Events

#### Audio/Video Toggle
```javascript
// Toggle audio
socket.emit('toggle-audio', {
  participantId: 'participant_id',
  enabled: true
});

socket.on('participant-audio-toggle', (data) => {
  const { participantId, enabled } = data;
  // Update UI to show audio state
});

// Toggle video
socket.emit('toggle-video', {
  participantId: 'participant_id',
  enabled: false
});

socket.on('participant-video-toggle', (data) => {
  const { participantId, enabled } = data;
  // Update UI to show video state
});
```

#### Screen Sharing
```javascript
// Start screen sharing
socket.emit('start-screen-share', {
  participantId: 'participant_id'
});

socket.on('screen-share-started', (data) => {
  const { participantId, participantName } = data;
  // Show screen sharing indicator
});

// Stop screen sharing
socket.emit('stop-screen-share', {
  participantId: 'participant_id'
});

socket.on('screen-share-stopped', (data) => {
  const { participantId, participantName } = data;
  // Hide screen sharing indicator
});

// Screen sharing signaling
socket.emit('screen-share-offer', { offer: offerData });
socket.on('screen-share-offer', (data) => { /* handle */ });

socket.emit('screen-share-answer', { answer: answerData });
socket.on('screen-share-answer', (data) => { /* handle */ });

socket.emit('screen-share-ice-candidate', { candidate: candidateData });
socket.on('screen-share-ice-candidate', (data) => { /* handle */ });
```

### Chat Events

#### Send/Receive Messages
```javascript
// Send chat message
socket.emit('chat-message', {
  id: 'message_id',
  sender: 'John Doe',
  message: 'Hello everyone!',
  timestamp: '2024-01-01T10:05:00Z',
  meetingCode: 'MEET123'
});

// Receive chat message
socket.on('chat-message', (data) => {
  const { id, sender, message, timestamp } = data;
  // Display message in chat UI
});
```

## WebRTC Configuration

### STUN/TURN Servers
```javascript
const rtcConfiguration = {
  iceServers: [
    { urls: 'stun:stun.l.google.com:19302' },
    { urls: 'stun:stun1.l.google.com:19302' },
    { urls: 'stun:stun.relay.metered.ca:80' },
    {
      urls: 'turn:global.relay.metered.ca:80',
      username: 'api_demo_user',
      credential: 'temp_password'
    },
    {
      urls: 'turn:global.relay.metered.ca:443',
      username: 'api_demo_user',
      credential: 'temp_password'
    }
  ],
  iceCandidatePoolSize: 10,
  bundlePolicy: 'max-bundle',
  rtcpMuxPolicy: 'require'
};
```

### Media Constraints

#### Camera/Microphone (Standard)
```javascript
const mediaConstraints = {
  audio: {
    echoCancellation: true,
    noiseSuppression: true,
    autoGainControl: true
  },
  video: {
    mandatory: {
      minWidth: '320',
      minHeight: '240',
      maxWidth: '1280',
      maxHeight: '720',
      minFrameRate: '15',
      maxFrameRate: '30'
    },
    facingMode: 'user'
  }
};
```

#### Screen Sharing (Multiple Fallbacks)
```javascript
const screenConstraints = [
  // High quality with audio
  {
    video: {
      mediaSource: 'screen',
      width: { max: 1920, ideal: 1280 },
      height: { max: 1080, ideal: 720 },
      frameRate: { max: 30, ideal: 15 }
    },
    audio: {
      echoCancellation: false,
      noiseSuppression: false
    }
  },
  // Medium quality without audio
  {
    video: {
      mediaSource: 'screen',
      width: { max: 1280, ideal: 854 },
      height: { max: 720, ideal: 480 },
      frameRate: { max: 15, ideal: 10 }
    },
    audio: false
  },
  // Basic compatibility
  {
    video: {
      mediaSource: 'screen',
      frameRate: { max: 10 }
    },
    audio: false
  },
  // Final fallback
  {
    video: true,
    audio: false
  }
];
```

## Error Handling

### Common Error Codes
- `NotAllowedError`: Permission denied for camera/microphone/screen
- `NotSupportedError`: Feature not supported on device/browser
- `AbortError`: User cancelled the operation
- `NetworkError`: Connection issues
- `TimeoutError`: Request timed out

### API Error Response Format
```json
{
  "success": false,
  "error": "error_code",
  "message": "Human readable error message",
  "details": {
    "field": "validation error details"
  }
}
```

## SFU Architecture Notes

The application is designed to work with SFU (Selective Forwarding Unit) backend:

1. **Peer Connection Management**: Each participant maintains connections to the SFU server rather than direct P2P connections
2. **Media Stream Forwarding**: SFU handles selective forwarding of media streams based on layout and bandwidth
3. **Scalability**: Supports many participants without exponential connection growth
4. **Quality Adaptation**: SFU can adapt stream quality based on network conditions

## Mobile Compatibility

### iOS Support
- Screen sharing: Limited support, requires iOS 11+
- Camera/microphone: Full support with permissions
- WebRTC: Supported in Safari and WKWebView

### Android Support  
- Screen sharing: Supported in Chrome 72+
- Camera/microphone: Full support with permissions
- WebRTC: Supported in Chrome and WebView

### Testing Recommendations

1. **Desktop Testing**: Chrome, Firefox, Safari, Edge
2. **Mobile Testing**: iOS Safari, Android Chrome
3. **Network Conditions**: Test on various connection speeds
4. **Device Testing**: Test on physical devices, not just simulators
5. **Permission Testing**: Test permission granting/denial scenarios

## Security Considerations

1. **HTTPS Required**: All WebRTC functionality requires HTTPS
2. **TURN Authentication**: Use temporary credentials for TURN servers
3. **Meeting Codes**: Generate secure, unique meeting codes
4. **Permission Validation**: Server-side validation of host permissions
5. **Rate Limiting**: Implement rate limiting on signaling messages