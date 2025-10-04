# WebRTC Implementation Guide

## Overview

This document describes the WebRTC implementation for real-time video and audio communication in the video conferencing app.

## What Was Added

### 1. WebRTC Service (`lib/services/webrtc_service.dart`)

A comprehensive service that handles:
- **Local Media Capture**: Captures camera and microphone using `getUserMedia`
- **Peer Connections**: Manages WebRTC peer connections for each participant
- **Media Streaming**: Handles local and remote media streams
- **Media Controls**: Toggle audio/video on/off, switch cameras

Key Features:
```dart
// Initialize camera and microphone
MediaStream? localStream = await webrtcService.initializeLocalMedia();

// Create peer connection for a participant
RTCPeerConnection? pc = await webrtcService.createPeerConnection(
  participantId,
  onIceCandidate: (candidate) { /* send via WebSocket */ },
  onAddStream: (stream) { /* display remote video */ },
);

// Toggle media
webrtcService.toggleAudio(enabled);
webrtcService.toggleVideo(enabled);
```

### 2. Updated Participant Grid (`lib/widgets/meeting/participant_grid.dart`)

Now displays actual video streams:
- Uses `RTCVideoRenderer` to display video
- Shows local stream for current user
- Shows remote streams for other participants
- Falls back to avatar when video is off

### 3. Permission Handling (`lib/utils/permission_helper.dart`)

Requests camera and microphone permissions:
```dart
bool hasPermissions = await PermissionHelper.requestCameraAndMicrophonePermissions();
```

### 4. WebRTC Signaling

Integrated WebRTC signaling via WebSocket:
- **Offer/Answer Exchange**: SDP negotiation between peers
- **ICE Candidate Exchange**: Network connectivity information
- **Automatic Peer Connection Setup**: When participants join/leave

## How It Works

### Meeting Flow

1. **User Creates/Joins Meeting**
   ```
   User → Request Permissions → Initialize Local Media → Connect WebSocket
   ```

2. **Participant Joins**
   ```
   New Participant → Create Peer Connection → Send Offer → Receive Answer → Connect
   ```

3. **Media Streaming**
   ```
   Local Stream → Peer Connection → Network → Remote Peer → Remote Stream Display
   ```

### Signaling Flow

```
Participant A                WebSocket Server              Participant B
     |                              |                            |
     |------- join-meeting -------->|                            |
     |                              |------- participant-joined ->|
     |                              |                            |
     |                              |<----- create-peer-conn -----|
     |<-------- offer --------------|                            |
     |                              |                            |
     |--------- answer ------------>|                            |
     |                              |-------- answer ----------->|
     |                              |                            |
     |<----- ice-candidate ---------|<----- ice-candidate -------|
     |------ ice-candidate -------->|------ ice-candidate ------>|
     |                              |                            |
     |========= MEDIA STREAMS ====================================|
```

## Configuration

### Media Constraints

Mobile-optimized constraints for better performance:

```dart
{
  'audio': {
    'echoCancellation': true,
    'noiseSuppression': true,
    'autoGainControl': true,
  },
  'video': {
    'mandatory': {
      'minWidth': '320',
      'minHeight': '240',
      'maxWidth': '1280',
      'maxHeight': '720',
      'minFrameRate': '15',
      'maxFrameRate': '30',
    },
    'facingMode': 'user',
  }
}
```

### ICE Servers

Using Google's public STUN servers:
```dart
{
  'iceServers': [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
  ]
}
```

For production, consider adding TURN servers for better connectivity.

## Testing

### Prerequisites

1. Physical devices (Android/iOS) or emulators with camera support
2. Backend server running with WebSocket support
3. At least 2 devices to test peer-to-peer communication

### Test Scenarios

#### 1. Local Media Capture
- [ ] Camera permission requested
- [ ] Microphone permission requested
- [ ] Local video displays in participant grid
- [ ] Can toggle video on/off
- [ ] Can toggle audio on/off

#### 2. Single Participant (Self)
- [ ] Create meeting as host
- [ ] See own video in participant grid
- [ ] Video shows live camera feed
- [ ] Audio/video controls work

#### 3. Two Participants
- [ ] Host creates meeting
- [ ] Participant joins with meeting code
- [ ] Both see each other's video
- [ ] Both can hear each other
- [ ] Toggle controls work for both

#### 4. Multiple Participants (3+)
- [ ] All participants visible in grid
- [ ] All video streams display correctly
- [ ] All audio channels work
- [ ] Late joiners see existing participants
- [ ] Participants leaving are handled correctly

### Testing Commands

```bash
# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios

# Build APK for testing
flutter build apk

# Build iOS for testing
flutter build ios
```

## Troubleshooting

### Camera/Microphone Not Working

**Problem**: Permissions denied or camera not accessible

**Solutions**:
1. Check permissions in device settings
2. Ensure no other app is using camera
3. Grant permissions when prompted
4. On iOS: Check Info.plist has usage descriptions
5. On Android: Check AndroidManifest.xml has permissions

### No Video Stream Displayed

**Problem**: Black screen or no video showing

**Solutions**:
1. Check if `localStream` is initialized
2. Verify `RTCVideoRenderer` is properly initialized
3. Check if video track is enabled
4. Ensure `srcObject` is set on renderer

### Peer Connection Failed

**Problem**: Can't see other participant's video

**Solutions**:
1. Check WebSocket connection is active
2. Verify signaling messages are being sent/received
3. Check ICE candidate exchange
4. Ensure both peers have initiated peer connections
5. Check network/firewall settings

### Audio Echo or Feedback

**Problem**: Hearing own voice or echo

**Solutions**:
1. Use headphones during testing
2. Ensure `echoCancellation` is enabled in constraints
3. Lower device volume
4. Keep devices physically separated during testing

## Architecture Decisions

### Why Peer-to-Peer?

- **Low Latency**: Direct connection between peers
- **Better Quality**: No server-side transcoding
- **Cost Effective**: Minimal server resources

### Why STUN Only (No TURN)?

- **Simplicity**: Easier setup for demo
- **Works in Most Cases**: NAT traversal works for most networks
- **Recommendation**: Add TURN servers for production

### Why Flutter WebRTC?

- **Native Performance**: Uses native WebRTC implementations
- **Cross-Platform**: Works on iOS, Android, Web, Desktop
- **Well Maintained**: Active community and updates

## Next Steps (Future Enhancements)

1. **Add TURN Servers**: For better connectivity in restrictive networks
2. **Add Screen Sharing**: Share screen content
3. **Add Recording**: Record meetings
4. **Add Quality Adaptation**: Adjust quality based on network
5. **Add SFU Support**: Scale to more participants
6. **Add Statistics**: Show connection quality metrics

## Resources

- [Flutter WebRTC Documentation](https://github.com/flutter-webrtc/flutter-webrtc)
- [WebRTC API Documentation](https://webrtc.org/)
- [Permission Handler Plugin](https://pub.dev/packages/permission_handler)

## Support

If video/audio is not working:
1. Check permissions are granted
2. Check backend WebSocket server is running
3. Check device has working camera/microphone
4. Check network connectivity
5. Check browser console/app logs for errors
