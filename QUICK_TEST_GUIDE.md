# Quick Test Guide - WebRTC Implementation

## 🚀 Quick Start (5 Minutes)

### Prerequisites
- ✅ 2 physical devices (Android/iOS) with cameras
- ✅ Flutter SDK installed
- ✅ Backend server running at configured URL
- ✅ Devices connected to internet

### Step 1: Build and Install (2 minutes)

**Device 1 (Host):**
```bash
# Connect device via USB
adb devices  # or check Xcode for iOS

# Build and install
flutter run -d <device_id>
```

**Device 2 (Participant):**
```bash
# Connect second device
flutter run -d <device_id_2>
```

### Step 2: Grant Permissions (30 seconds)

On **both devices**, when prompted:
- ✅ Allow camera access
- ✅ Allow microphone access

### Step 3: Create Meeting (1 minute)

**On Device 1:**
1. Fill in "Create New Meeting" form:
   - Host Name: `John`
   - Meeting Title: `Test Meeting`
   - Description: `WebRTC Test`
2. Tap "🚀 Create Meeting"
3. **Note the meeting code** (e.g., `ABC123`)
4. You should see YOUR video feed

### Step 4: Join Meeting (1 minute)

**On Device 2:**
1. Fill in "Join Meeting" form:
   - Meeting Code: `ABC123` (from Device 1)
   - Your Name: `Jane`
2. Tap "🔗 Join Meeting"
3. You should see BOTH videos (yours + host's)

### Step 5: Test Media Controls (1 minute)

**Test on both devices:**
- ✅ Tap video button → Camera should turn off/on
- ✅ Tap audio button → Mic should mute/unmute
- ✅ Speak → Other device should hear you
- ✅ Wave at camera → Other device should see you

## ✅ Success Criteria

After these steps, you should have:
- [x] Both devices show live video feeds
- [x] Audio working in both directions
- [x] Media controls functional
- [x] No errors in console

## 📸 Screenshot Checklist

Take screenshots showing:
1. Permission dialogs (camera, microphone)
2. Single participant (host only)
3. Two participants (split screen)
4. Video toggle (on vs off states)
5. Audio toggle (muted vs unmuted)
6. Multiple participants if available

## 🐛 Common Issues & Quick Fixes

### Issue: "Camera permission denied"
**Fix:** Open device Settings → App Permissions → Grant camera/mic access

### Issue: "No video showing"
**Fix:** 
1. Check permissions granted
2. Restart app
3. Check another app can access camera

### Issue: "Can't hear audio"
**Fix:**
1. Check volume on both devices
2. Use headphones to avoid feedback
3. Check microphone permission granted

### Issue: "Participant can't join"
**Fix:**
1. Verify meeting code is correct
2. Check backend server is running
3. Check WebSocket connection (look for connection icon)

### Issue: "Black screen"
**Fix:**
1. Close other apps using camera
2. Restart device
3. Check device camera works in default camera app

## 🔧 Build Commands

### Android APK
```bash
flutter build apk --release
# APK location: build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
flutter build ios --release
# Then use Xcode to sign and install
```

### Debug Mode (with hot reload)
```bash
flutter run
```

## 📊 Performance Check

While testing, monitor:
- **CPU Usage**: Should be < 50% on modern devices
- **Memory**: Should be < 500MB
- **Battery**: Expect higher drain (camera/video processing)
- **Network**: ~1-3 Mbps per participant

## 🎯 Advanced Testing

### Test Multiple Participants
```bash
# Run on 3+ devices
Device 1: Host creates meeting
Device 2: Participant 1 joins
Device 3: Participant 2 joins
Device 4: Participant 3 joins

# Verify:
- All see each other
- Grid layout adapts (2x2 for 4 people)
- All audio channels work
```

### Test Network Conditions
```bash
# Use network throttling
# Android: Developer Options → Network throttling
# iOS: Network Link Conditioner

Test scenarios:
- Good 4G: Should work great
- 3G: May reduce quality
- Poor network: May disconnect
```

### Test Device Rotation
```bash
# Rotate devices between portrait/landscape
- Video should adapt
- Grid should reflow
- No crashes
```

## 📝 Test Report Template

After testing, document:

```
## Test Results

**Date:** [YYYY-MM-DD]
**Tester:** [Your Name]
**Devices:** 
- Device 1: [Android/iOS Version, Model]
- Device 2: [Android/iOS Version, Model]

### Test Cases

| Test Case | Status | Notes |
|-----------|--------|-------|
| Permissions granted | ✅ / ❌ | |
| Video shows (host) | ✅ / ❌ | |
| Video shows (participant) | ✅ / ❌ | |
| Audio works (both ways) | ✅ / ❌ | |
| Video toggle works | ✅ / ❌ | |
| Audio toggle works | ✅ / ❌ | |
| Multiple participants | ✅ / ❌ | |
| Connection stable | ✅ / ❌ | |

### Screenshots
- [ ] Uploaded to /screenshots directory
- [ ] Named descriptively

### Issues Found
1. [List any issues]
2. [With details]

### Overall Rating
- [ ] Ready for demo
- [ ] Needs fixes
- [ ] Critical issues
```

## 🎬 Demo Script

For demonstrations:

```
1. "Let me show you our video conferencing feature..."
2. "First, I'll create a meeting on this device..."
   [Create meeting, show video feed]
3. "You can see my live camera feed here..."
4. "Now, let's join from another device..."
   [Join on second device]
5. "Both participants can now see and hear each other..."
6. "We can toggle video and audio controls..."
   [Demo controls]
7. "Multiple participants can join..."
   [If available, show 3+ participants]
8. "The grid automatically adapts to the number of participants"
```

## 🔍 Debug Mode

Enable verbose logging:

```dart
// In WebRTCService
print('Local stream initialized: ${_localStream != null}');
print('Peer connections: ${_peerConnections.length}');
print('Remote streams: ${_remoteStreams.length}');

// In AppProvider
print('Media event: $eventType');
print('Current participant ID: $_currentParticipantId');
```

Check console output for:
- Permission requests
- Stream initialization
- Peer connection states
- Signaling messages
- Error messages

## 📞 Support Checklist

Before asking for help, verify:
- [ ] Permissions granted
- [ ] Backend server running
- [ ] Correct API URL in config
- [ ] WebSocket connection active
- [ ] Device camera/mic working
- [ ] Flutter version compatible
- [ ] Dependencies installed (`flutter pub get`)
- [ ] No build errors
- [ ] Checked console logs

## 🎓 Learning Resources

To understand the code:
1. Read `WEBRTC_IMPLEMENTATION.md` - Technical details
2. Read `ARCHITECTURE_DIAGRAM.md` - System architecture
3. Read `IMPLEMENTATION_NOTES.md` - Summary and troubleshooting
4. Check `lib/services/webrtc_service.dart` - Core WebRTC code
5. Check `lib/providers/app_provider.dart` - State management

## 📈 Next Steps

After successful testing:
1. ✅ Mark implementation as complete
2. 📸 Upload screenshots
3. 📝 Document any issues found
4. 🚀 Deploy to production (with proper TURN servers)
5. 📊 Monitor performance in production
6. 🔧 Optimize based on user feedback

## 💡 Pro Tips

1. **Use headphones** when testing on same device/room to avoid audio feedback
2. **Test on real network** not just localhost/LAN
3. **Try different lighting** conditions for camera
4. **Test with poor network** to see behavior under stress
5. **Keep devices updated** for best WebRTC support
6. **Monitor battery drain** during extended sessions
7. **Test different orientations** (portrait/landscape)
8. **Try with/without WiFi** to test cellular data

## 🎉 Success!

If all tests pass, congratulations! You now have a working video conferencing app with:
- ✅ Real-time video streaming
- ✅ Two-way audio communication
- ✅ Multiple participant support
- ✅ Media controls
- ✅ Mobile-optimized performance

Time to celebrate! 🎊

---

**Questions?** Check other documentation files or create an issue in the repository.
