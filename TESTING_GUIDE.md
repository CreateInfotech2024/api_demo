# Video Calling App Testing Guide

## Overview
This guide provides comprehensive testing procedures for the Google Meet/Zoom-like video calling application with SFU backend support.

## Prerequisites

### Development Environment
```bash
# Install Flutter dependencies
flutter pub get

# Run basic tests
flutter test

# Check Flutter doctor
flutter doctor
```

### Backend Requirements
- Backend server running at `https://krishnabarasiya.space`
- Socket.IO server accessible
- STUN/TURN servers configured
- API endpoints responding

## Testing Checklist

### 1. Basic Functionality Tests

#### ✅ App Launch
- [ ] App launches without errors
- [ ] Home screen displays properly
- [ ] Navigation works correctly
- [ ] All service providers are initialized

#### ✅ Media Permissions
- [ ] Camera permission request works
- [ ] Microphone permission request works
- [ ] Permission denial handled gracefully
- [ ] Settings link works for permission management

#### ✅ API Connectivity
- [ ] Health check endpoint responds
- [ ] Live courses API returns data
- [ ] Course creation works
- [ ] Error handling for offline scenarios

### 2. Video Calling Core Features

#### ✅ Meeting Creation/Joining
- [ ] Host can create meeting successfully
- [ ] Meeting code is generated
- [ ] Participants can join with valid code
- [ ] Invalid codes show appropriate errors
- [ ] Late joiners see existing participants

#### ✅ Audio/Video Controls
- [ ] Camera toggle works correctly
- [ ] Microphone toggle works correctly
- [ ] Visual indicators update properly
- [ ] Other participants see toggle states
- [ ] Audio quality is acceptable
- [ ] Video quality is appropriate for platform

#### ✅ Screen Sharing
- [ ] Screen sharing button is available to all participants
- [ ] Permission request appears correctly
- [ ] Screen content is shared clearly
- [ ] Screen sharing stops gracefully
- [ ] Other participants see screen content
- [ ] Works on both mobile and desktop

### 3. Mobile Device Testing

#### ✅ Android Testing
**Required:** Physical Android device with Chrome 72+

- [ ] App installs and runs on Android
- [ ] Camera/microphone work correctly
- [ ] Screen sharing functions (limited support expected)
- [ ] Network switching (WiFi ↔ Mobile data) works
- [ ] Background/foreground transitions work
- [ ] Battery optimization doesn't kill connections
- [ ] Audio routing works (speaker/earpiece/headphones)

#### ✅ iOS Testing  
**Required:** Physical iOS device with Safari 11+

- [ ] App runs in Safari/WKWebView
- [ ] Camera/microphone permissions work
- [ ] Screen sharing limitations are handled gracefully
- [ ] Network transitions work smoothly
- [ ] Background audio continues appropriately
- [ ] iOS-specific UI considerations work

### 4. Multi-Participant Testing

#### ✅ Two Participants
- [ ] Host and one participant can see/hear each other
- [ ] Video streams display correctly
- [ ] Audio is synchronized
- [ ] Chat messages work bidirectionally
- [ ] Screen sharing works between participants

#### ✅ Multiple Participants (3-6)
- [ ] All participants visible in grid view
- [ ] Speaker view shows active speaker
- [ ] Audio mixing works correctly
- [ ] Performance remains acceptable
- [ ] Chat works for all participants
- [ ] Screen sharing visible to all

#### ✅ Stress Testing (6+ participants)
- [ ] Performance degrades gracefully
- [ ] Mobile devices handle load appropriately
- [ ] Network bandwidth is managed well
- [ ] UI remains responsive
- [ ] Error handling for overload scenarios

### 5. Network Condition Testing

#### ✅ Good Connection
- [ ] HD video quality maintained
- [ ] Low latency audio/video
- [ ] Screen sharing is smooth
- [ ] All features work optimally

#### ✅ Moderate Connection
- [ ] Quality adapts appropriately
- [ ] No major disruptions
- [ ] Audio prioritized over video
- [ ] Screen sharing adjusts quality

#### ✅ Poor Connection
- [ ] Graceful quality degradation
- [ ] Audio-only fallback works
- [ ] Reconnection attempts succeed
- [ ] User feedback about connection issues

#### ✅ Connection Loss/Recovery
- [ ] Reconnection happens automatically
- [ ] Participants rejoin successfully
- [ ] State is restored appropriately
- [ ] No data loss in chat

### 6. Error Scenario Testing

#### ✅ Permission Errors
- [ ] Camera blocked: appropriate message
- [ ] Microphone blocked: appropriate message
- [ ] Screen sharing blocked: helpful guidance
- [ ] Settings links work correctly

#### ✅ Network Errors
- [ ] Backend unavailable: offline mode works
- [ ] Socket disconnection: reconnection works
- [ ] API timeouts: handled gracefully
- [ ] TURN server failure: fallback works

#### ✅ Device Errors
- [ ] Camera in use by another app
- [ ] Microphone not available
- [ ] Low memory conditions
- [ ] Background app limitations

### 7. Browser Compatibility

#### ✅ Desktop Browsers
- [ ] **Chrome**: Full functionality
- [ ] **Firefox**: WebRTC compatibility
- [ ] **Safari**: Basic functionality
- [ ] **Edge**: Standard features work

#### ✅ Mobile Browsers
- [ ] **Android Chrome**: Optimized experience
- [ ] **iOS Safari**: Core features work
- [ ] **Mobile Firefox**: Basic compatibility
- [ ] **Samsung Internet**: Standard features

### 8. Performance Testing

#### ✅ Resource Usage
- [ ] CPU usage remains reasonable
- [ ] Memory usage doesn't leak
- [ ] Battery drain is acceptable on mobile
- [ ] Network bandwidth is optimized

#### ✅ Scaling
- [ ] Performance with 2 participants
- [ ] Performance with 4 participants
- [ ] Performance with 6+ participants
- [ ] Mobile performance at scale

## Testing Tools and Commands

### Automated Testing
```bash
# Run all tests
flutter test

# Run integration tests (if available)
flutter test integration_test/

# Performance testing
flutter drive --target=test_driver/perf_test.dart
```

### Manual Testing Tools

#### Browser Developer Tools
```javascript
// Test WebRTC connections in browser console
console.log('Peer connections:', Object.keys(window.peerConnections || {}));

// Check media streams
navigator.mediaDevices.enumerateDevices().then(console.log);

// Monitor WebRTC stats
setInterval(() => {
  // Log connection statistics
}, 5000);
```

#### Network Simulation
- Chrome DevTools: Network tab > Throttling
- Use mobile hotspot for real mobile network testing
- Test with VPN for different geographic locations

### Debug Information

#### Client-Side Debugging
```dart
// Enable WebRTC logging in Flutter
await webrtcService.logConnectionStatus();

// Get detailed statistics
final stats = await webrtcService.getConnectionStats();
print('Connection stats: $stats');
```

#### Backend Monitoring
```bash
# Check backend health
curl -v https://krishnabarasiya.space/api/health

# Monitor Socket.IO connections
# Check server logs for connection events
```

## Expected Results

### Success Criteria
- ✅ All participants can see and hear each other clearly
- ✅ Screen sharing works on desktop and has graceful mobile fallback
- ✅ Mobile devices provide acceptable quality and performance
- ✅ Network issues are handled gracefully with reconnection
- ✅ UI is responsive and user-friendly across platforms
- ✅ Battery usage on mobile is reasonable
- ✅ API integration works smoothly with offline fallback

### Performance Benchmarks
- **Video Quality**: 480p minimum, 720p preferred on desktop
- **Audio Quality**: Clear speech, minimal latency (<500ms)
- **Connection Time**: Join meeting in <10 seconds
- **Screen Sharing**: <2 seconds to start sharing
- **Mobile Battery**: <10% drain per hour of usage
- **Memory Usage**: <100MB per participant stream

## Troubleshooting Common Issues

### Camera/Microphone Not Working
1. Check browser permissions in settings
2. Verify no other apps are using camera/microphone
3. Try refreshing the page
4. Check device privacy settings (mobile)

### Screen Sharing Not Available
1. Verify using supported browser (Chrome/Firefox desktop)
2. Check screen sharing permissions
3. Try refreshing the page
4. Use desktop browser instead of mobile

### Connection Issues
1. Check internet connection stability
2. Try different network (WiFi vs mobile data)
3. Clear browser cache and cookies
4. Restart browser/app

### Poor Video/Audio Quality
1. Check network bandwidth
2. Close other bandwidth-intensive applications
3. Move closer to WiFi router
4. Try audio-only mode

### Backend Connection Failed
1. Verify backend server is running
2. Check API endpoint accessibility
3. Use offline/P2P mode if available
4. Contact backend administrator

## Reporting Issues

When reporting issues, please include:

### Environment Information
- Device type and OS version
- Browser name and version
- Network connection type
- Backend server status

### Issue Description
- Steps to reproduce
- Expected vs actual behavior
- Screenshots/screen recordings if applicable
- Console error messages
- WebRTC connection statistics

### Test Data
```javascript
// Include this debug info with bug reports
{
  "userAgent": navigator.userAgent,
  "deviceType": "mobile/desktop",
  "connectionType": "wifi/mobile",
  "participantCount": 3,
  "features": {
    "screenSharing": true/false,
    "audioEnabled": true/false,
    "videoEnabled": true/false
  },
  "errors": ["error messages here"]
}
```

## Deployment Checklist

Before deploying to production:

- [ ] All critical tests pass
- [ ] Mobile testing completed on physical devices  
- [ ] Performance benchmarks met
- [ ] Error handling verified
- [ ] Documentation updated
- [ ] Backend API endpoints verified
- [ ] STUN/TURN servers configured
- [ ] SSL certificates valid
- [ ] Monitoring and logging configured

## Continuous Testing

### Automated Monitoring
- Set up automated tests for critical user flows
- Monitor API endpoint availability
- Track performance metrics over time
- Alert on error rate increases

### User Feedback
- Collect user feedback on video/audio quality
- Monitor support tickets for common issues
- Track feature usage analytics
- Regular user satisfaction surveys