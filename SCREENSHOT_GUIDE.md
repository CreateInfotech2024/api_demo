# Screenshot Guide - Expected UI Behavior

## What to Expect After Implementation

This guide shows what you should see when the WebRTC implementation is working correctly.

## 1. Permission Requests

### First Launch
When you create or join a meeting for the first time, you'll see:

**iOS:**
```
┌─────────────────────────────────────┐
│  "api_demo" Would Like to           │
│  Access the Camera                  │
│                                     │
│  This app needs access to your     │
│  camera for video conferencing     │
│                                     │
│  [ Don't Allow ]  [ OK ]           │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  "api_demo" Would Like to           │
│  Access the Microphone              │
│                                     │
│  This app needs access to your     │
│  microphone for audio communication│
│                                     │
│  [ Don't Allow ]  [ OK ]           │
└─────────────────────────────────────┘
```

**Android:**
```
┌─────────────────────────────────────┐
│  Allow api_demo to take pictures    │
│  and record video?                  │
│                                     │
│  [ DENY ]  [ ALLOW ]               │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  Allow api_demo to record audio?    │
│                                     │
│  [ DENY ]  [ ALLOW ]               │
└─────────────────────────────────────┘
```

**Expected**: Both permissions should be granted for full functionality.

## 2. Home Screen

### Create Meeting Section
```
┌─────────────────────────────────────┐
│  Beauty LMS Live Courses            │
│  ═══════════════════════════════════│
│                                     │
│  🎥 Create New Meeting              │
│  ─────────────────────────────────  │
│  Host Name:    [John Doe         ]  │
│  Meeting Title:[Team Standup     ]  │
│  Description:  [Daily sync...    ]  │
│                                     │
│  [🚀 Create Meeting]                │
│                                     │
└─────────────────────────────────────┘
```

### Join Meeting Section
```
│  👥 Join Existing Meeting           │
│  ─────────────────────────────────  │
│  Meeting Code: [ABC123          ]  │
│  Your Name:    [Jane Smith      ]  │
│                                     │
│  [🔗 Join Meeting]                  │
└─────────────────────────────────────┘
```

## 3. Meeting Screen - Single Participant (Host Only)

When host creates a meeting and is alone:

```
┌─────────────────────────────────────┐
│  Team Standup          [💬] [👥] [🚪]│
│  Code: ABC123                       │
├─────────────────────────────────────┤
│  Daily sync meeting                 │
│  Host: John Doe • 1 participant     │
│  🟢 LIVE  Started: 14:30            │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │   📹 LIVE VIDEO FEED        │   │
│  │   (Shows camera view)       │   │
│  │                             │   │
│  │                             │   │
│  │   ┌───────────────────┐     │   │
│  │   │ 🎤 John Doe [HOST]│     │   │
│  │   └───────────────────┘     │   │
│  └─────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│  [ 📹 Video] [🎤 Audio] [🖥️ Share] │
│  [💬 Chat] [📞 Leave]               │
└─────────────────────────────────────┘
```

**Expected Behavior:**
- ✅ Live camera feed visible in the video tile
- ✅ Camera view shows YOUR face (front camera by default)
- ✅ Video is mirrored (like looking in a mirror)
- ✅ Name overlay shows "John Doe [HOST]"
- ✅ Green microphone icon (audio enabled)
- ✅ Yellow border around host's video tile

## 4. Meeting Screen - Two Participants

When participant joins the host:

```
┌─────────────────────────────────────┐
│  Team Standup          [💬] [👥] [🚪]│
│  Code: ABC123                       │
├─────────────────────────────────────┤
│  Daily sync meeting                 │
│  Host: John Doe • 2 participants    │
│  🟢 LIVE  Started: 14:30            │
├─────────────────────────────────────┤
│                                     │
│  ┌────────────┐  ┌────────────┐    │
│  │   [VIDEO]  │  │   [VIDEO]  │    │
│  │   John's   │  │   Jane's   │    │
│  │   Camera   │  │   Camera   │    │
│  │            │  │            │    │
│  │ 🎤 John D. │  │ 🎤 Jane S. │    │
│  │   [HOST]   │  │            │    │
│  └────────────┘  └────────────┘    │
│                                     │
├─────────────────────────────────────┤
│  [ 📹 Video] [🎤 Audio] [🖥️ Share] │
│  [💬 Chat] [📞 Leave]               │
└─────────────────────────────────────┘
```

**Expected Behavior:**
- ✅ Host sees their own video on the left
- ✅ Host sees participant's video on the right
- ✅ Participant sees host's video on the left
- ✅ Participant sees their own video on the right
- ✅ Both videos show LIVE camera feeds
- ✅ Yellow border only on host's tile
- ✅ Both can hear each other's audio
- ✅ Green mic icons for both (if unmuted)

## 5. Meeting Screen - Multiple Participants (4)

With 4 participants in a 2x2 grid:

```
┌─────────────────────────────────────┐
│  Team Standup          [💬] [👥] [🚪]│
│  Code: ABC123                       │
├─────────────────────────────────────┤
│  Host: John • 4 participants        │
├─────────────────────────────────────┤
│                                     │
│  ┌──────┐  ┌──────┐                │
│  │[VIDEO]│  │[VIDEO]│                │
│  │John  │  │Jane  │                │
│  │[HOST]│  │      │                │
│  └──────┘  └──────┘                │
│                                     │
│  ┌──────┐  ┌──────┐                │
│  │[VIDEO]│  │[VIDEO]│                │
│  │Mike  │  │Sarah │                │
│  └──────┘  └──────┘                │
│                                     │
├─────────────────────────────────────┤
│  [📹] [🎤] [🖥️] [💬] [📞]           │
└─────────────────────────────────────┘
```

## 6. Media Controls States

### Video ON
```
┌─────────────────────────────────┐
│        📹 LIVE VIDEO            │
│    (Camera feed showing)        │
│                                 │
│  ┌───────────────────────┐      │
│  │ 🎤 John Doe [HOST]    │      │
│  └───────────────────────┘      │
└─────────────────────────────────┘
```
- Blue video button in controls
- Green mic icon in overlay
- Live video visible

### Video OFF
```
┌─────────────────────────────────┐
│                                 │
│         👤 JD                   │
│     (Avatar/Initial)            │
│                                 │
│  ┌───────────────────────┐  🚫📹│
│  │ 🎤 John Doe [HOST]    │      │
│  └───────────────────────┘      │
└─────────────────────────────────┘
```
- Red/gray video button in controls
- Red camera-off icon in top-right
- Avatar with initials showing

### Audio OFF (Muted)
```
┌─────────────────────────────────┐
│        📹 LIVE VIDEO            │
│    (Camera feed showing)        │
│                                 │
│  ┌───────────────────────┐      │
│  │ 🔇 John Doe [HOST]    │      │
│  └───────────────────────┘      │
└─────────────────────────────────┘
```
- Red/gray mic button in controls
- Red mic-off icon in overlay

## 7. Control Buttons

Bottom bar with 5 buttons:

```
┌─────────────────────────────────────┐
│    (O)      (O)      (O)      (O)   (O)
│   Video    Audio   Share    Chat   Leave
```

**Active States:**
- 🟦 **Blue** = Video ON
- 🟩 **Green** = Audio ON  
- 🟧 **Orange** = Sharing
- 🟪 **Purple** = Chat open
- 🟥 **Red** = Leave (always red)

**Inactive States:**
- ⚪ **Red/Gray** = Disabled

## 8. Chat Panel

When chat button is toggled:

```
┌─────────────────────────────────────┐
│  Team Standup          [📹] [👥] [🚪]│
├─────────────────────────────────────┤
│  💬 Chat Messages                   │
│  ─────────────────────────────────  │
│                                     │
│  System: Jane joined the meeting    │
│  14:31                              │
│                                     │
│  John: Hi everyone!                 │
│  14:32                              │
│                                     │
│  Jane: Hello!                       │
│  14:32                              │
│                                     │
│  ─────────────────────────────────  │
│  [Type a message...         ] [📤]  │
└─────────────────────────────────────┘
```

## 9. Participants List

When participants button is tapped:

```
┌─────────────────────────────────────┐
│  Participants (2)                   │
│  ─────────────────────────────────  │
│                                     │
│  👤 John Doe [HOST]                 │
│     Joined: 14:30                   │
│                       📹 ON  🎤 ON  │
│                                     │
│  👤 Jane Smith                      │
│     Joined: 14:31                   │
│                       📹 ON  🎤 ON  │
│                                     │
│  ─────────────────────────────────  │
│  [Close]                            │
└─────────────────────────────────────┘
```

## Testing Checklist

Use this to verify your implementation:

### Visual Tests
- [ ] Camera feed visible when video ON
- [ ] Avatar visible when video OFF  
- [ ] Host has yellow border
- [ ] Participant names displayed correctly
- [ ] HOST badge shown only for host
- [ ] Mic icons show correct state (green/red)
- [ ] Video-off icons appear when camera disabled

### Functional Tests
- [ ] Can toggle video on/off
- [ ] Can toggle audio on/off
- [ ] Video feed responds to camera changes
- [ ] Multiple participants show in grid
- [ ] Grid layout adjusts (1, 4, 9+ tiles)
- [ ] Chat button toggles panel
- [ ] Participants list shows all users

### Audio/Video Tests
- [ ] Can see own camera feed
- [ ] Can see other participants' video
- [ ] Can hear other participants' audio
- [ ] Video is smooth (not choppy)
- [ ] Audio has no echo (use headphones)
- [ ] Late joiners see existing participants

## Common Issues & What You'll See

### ❌ Permissions Denied
```
┌─────────────────────────────────┐
│  ⚠️ Camera and microphone       │
│     permissions are required    │
│                                 │
│  [Open Settings]                │
└─────────────────────────────────┘
```

### ❌ No Camera/Mic Access
```
┌─────────────────────────────────┐
│  ❌ Failed to access            │
│     camera/microphone           │
│                                 │
│  Check device settings          │
└─────────────────────────────────┘
```

### ❌ WebSocket Disconnected
```
┌─────────────────────────────────┐
│  🔴 Disconnected                │
│     Attempting to reconnect...  │
└─────────────────────────────────┘
```

### ✅ Everything Working
```
┌─────────────────────────────────┐
│  🟢 Connected • 2 participants  │
│                                 │
│  [LIVE VIDEO FEEDS VISIBLE]     │
│  [AUDIO WORKING]                │
└─────────────────────────────────┘
```

## Tips for Taking Screenshots

1. **Use Two Physical Devices**: Best way to test video/audio
2. **Grant All Permissions**: Required for full functionality
3. **Good Lighting**: Ensures camera feed is visible in screenshots
4. **Test All States**: Video on/off, audio on/off, multiple participants
5. **Capture UI Elements**: Show controls, overlays, indicators

## Screenshot Naming Convention

When taking screenshots for documentation:
- `screenshot_1_permissions.png` - Permission dialogs
- `screenshot_2_home.png` - Home screen
- `screenshot_3_single_participant.png` - Host only
- `screenshot_4_two_participants.png` - Host + 1 participant
- `screenshot_5_multiple_participants.png` - 4+ participants
- `screenshot_6_controls.png` - Bottom controls
- `screenshot_7_chat.png` - Chat panel
- `screenshot_8_participants_list.png` - Participants modal
